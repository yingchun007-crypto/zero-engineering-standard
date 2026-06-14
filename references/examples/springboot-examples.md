# Spring Boot Examples

仅在初始化项目、补齐基础设施、或需要完整样例时读取。项目已有实现优先；如项目无统一实现，优先按本文模板保持一致。

## 推荐包结构

```text
common
├── entity/BaseEntity.java
├── exception/BusinessException.java
├── exception/GlobalExceptionHandler.java
├── result/ApiResult.java
├── result/PageResult.java
├── result/ApiResultAssert.java
└── result/ErrorCode.java
config
├── MybatisPlusConfig.java
└── MybatisPlusMetaObjectHandler.java
module/user
├── controller/UserController.java
├── dto/UserCreateDTO.java
├── dto/UserQueryDTO.java
├── entity/User.java
├── mapper/UserMapper.java
├── service/UserService.java
├── service/impl/UserServiceImpl.java
├── vo/UserVO.java
└── convert/UserConvert.java
```

## ApiResult

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "统一响应结果")
public class ApiResult<T> {

    @Schema(description = "业务状态码", example = "200")
    private Integer code;

    @Schema(description = "响应消息", example = "操作成功")
    private String msg;

    @Schema(description = "响应数据")
    private T data;

    public static <T> ApiResult<T> ok() {
        return new ApiResult<>(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMsg(), null);
    }

    public static <T> ApiResult<T> ok(T data) {
        return new ApiResult<>(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMsg(), data);
    }

    public static <T> ApiResult<T> ok(String msg, T data) {
        return new ApiResult<>(ErrorCode.SUCCESS.getCode(), msg, data);
    }

    public static <T> ApiResult<T> error(ErrorCode errorCode) {
        return new ApiResult<>(errorCode.getCode(), errorCode.getMsg(), null);
    }

    public static <T> ApiResult<T> error(Integer code, String msg) {
        return new ApiResult<>(code, msg, null);
    }
}
```

## ErrorCode

```java
@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    SUCCESS(200, "操作成功"),
    PARAM_ERROR(400, "请求参数错误"),
    UNAUTHORIZED(401, "用户未登录"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    CONFLICT(409, "资源冲突"),
    BUSINESS_ERROR(1000, "业务处理失败"),
    SYSTEM_ERROR(500, "系统繁忙，请稍后重试"),

    USER_NOT_FOUND(2001, "用户不存在"),
    USER_MOBILE_EXISTS(2002, "手机号已存在");

    private final Integer code;
    private final String msg;
}
```

## BusinessException

```java
@Getter
public class BusinessException extends RuntimeException {

    private final Integer code;

    public BusinessException(String message) {
        super(message);
        this.code = ErrorCode.BUSINESS_ERROR.getCode();
    }

    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMsg());
        this.code = errorCode.getCode();
    }
}
```

## ApiResultAssert

```java
public final class ApiResultAssert {

    private ApiResultAssert() {
    }

    public static void isTrue(boolean expression, ErrorCode errorCode) {
        if (!expression) {
            throw new BusinessException(errorCode);
        }
    }

    public static void isTrue(boolean expression, Integer code, String message) {
        if (!expression) {
            throw new BusinessException(code, message);
        }
    }

    public static void isFalse(boolean expression, ErrorCode errorCode) {
        if (expression) {
            throw new BusinessException(errorCode);
        }
    }

    public static void isFalse(boolean expression, Integer code, String message) {
        if (expression) {
            throw new BusinessException(code, message);
        }
    }

    public static void notNull(Object object, ErrorCode errorCode) {
        if (object == null) {
            throw new BusinessException(errorCode);
        }
    }

    public static void notNull(Object object, Integer code, String message) {
        if (object == null) {
            throw new BusinessException(code, message);
        }
    }
}
```

## GlobalExceptionHandler

```java
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ApiResult<Void> handleBusinessException(BusinessException ex) {
        return ApiResult.error(ex.getCode(), ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResult<Void> handleMethodArgumentNotValidException(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .findFirst()
                .map(FieldError::getDefaultMessage)
                .orElse("请求参数校验失败");
        return ApiResult.error(ErrorCode.PARAM_ERROR.getCode(), message);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ApiResult<Void> handleConstraintViolationException(ConstraintViolationException ex) {
        String message = ex.getConstraintViolations()
                .stream()
                .findFirst()
                .map(ConstraintViolation::getMessage)
                .orElse("请求参数校验失败");
        return ApiResult.error(ErrorCode.PARAM_ERROR.getCode(), message);
    }

    @ExceptionHandler(Exception.class)
    public ApiResult<Void> handleException(Exception ex) {
        log.error("system exception", ex);
        return ApiResult.error(ErrorCode.SYSTEM_ERROR);
    }
}
```

## PageResult

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "分页响应")
public class PageResult<T> {

    @Schema(description = "当前页码", example = "1")
    private Long pageNo;

    @Schema(description = "每页数量", example = "10")
    private Long pageSize;

    @Schema(description = "总记录数", example = "100")
    private Long total;

    @Schema(description = "总页数", example = "10")
    private Long pages;

    @Schema(description = "当前页数据")
    private List<T> records;

    public static <T> PageResult<T> of(IPage<T> page) {
        if (page == null) {
            return empty();
        }
        return new PageResult<>(page.getCurrent(), page.getSize(), page.getTotal(), page.getPages(), page.getRecords());
    }

    public static <S, T> PageResult<T> of(IPage<S> page, Function<S, T> converter) {
        if (page == null) {
            return empty();
        }
        List<T> records = page.getRecords() == null
                ? Collections.emptyList()
                : page.getRecords().stream().map(converter).toList();
        return new PageResult<>(page.getCurrent(), page.getSize(), page.getTotal(), page.getPages(), records);
    }

    public static <T> PageResult<T> empty() {
        return new PageResult<>(1L, 0L, 0L, 0L, Collections.emptyList());
    }
}
```

## BaseEntity

```java
@Data
public class BaseEntity {

    @TableId(type = IdType.AUTO)
    @Schema(description = "主键ID")
    private Long id;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableField(fill = FieldFill.INSERT)
    @Schema(description = "创建人ID")
    private Long createBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @Schema(description = "更新人ID")
    private Long updateBy;

    @TableLogic
    @Schema(description = "逻辑删除：0-未删除，1-已删除")
    private Integer deleted;
}
```

## MyBatis-Plus 自动填充

```java
@Component
public class MybatisPlusMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDateTime now = LocalDateTime.now();
        strictInsertFill(metaObject, "createTime", LocalDateTime.class, now);
        strictInsertFill(metaObject, "updateTime", LocalDateTime.class, now);
        strictInsertFill(metaObject, "deleted", Integer.class, 0);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }
}
```

## DTO / Query / VO

```java
@Data
@Schema(description = "创建用户请求")
public class UserCreateDTO {

    @NotBlank(message = "用户名不能为空")
    @Size(max = 32, message = "用户名长度不能超过32个字符")
    @Schema(description = "用户名", requiredMode = Schema.RequiredMode.REQUIRED)
    private String username;

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    @Schema(description = "手机号", requiredMode = Schema.RequiredMode.REQUIRED)
    private String mobile;
}

@Data
@Schema(description = "用户分页查询请求")
public class UserQueryDTO {

    @Min(value = 1, message = "页码不能小于1")
    @Schema(description = "页码，从1开始", example = "1")
    private Long pageNo = 1L;

    @Min(value = 1, message = "每页数量不能小于1")
    @Max(value = 100, message = "每页数量不能大于100")
    @Schema(description = "每页数量，最大100", example = "10")
    private Long pageSize = 10L;

    @Schema(description = "用户名，支持模糊查询")
    private String username;
}

@Data
@Schema(description = "用户响应")
public class UserVO {
    private Long id;
    private String username;
    private String mobile;
}
```

## Controller

```java
@Validated
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "用户管理")
public class UserController {

    private final UserService userService;

    @Operation(summary = "分页查询用户")
    @GetMapping
    public ApiResult<PageResult<UserVO>> pageUsers(@Validated UserQueryDTO query) {
        return ApiResult.ok(userService.pageUsers(query));
    }

    @Operation(summary = "查询用户详情")
    @GetMapping("/{userId}")
    public ApiResult<UserVO> getUser(@PathVariable("userId") @NotNull(message = "用户ID不能为空") Long userId) {
        return ApiResult.ok(userService.getUser(userId));
    }

    @Operation(summary = "创建用户")
    @PostMapping
    public ApiResult<UserVO> createUser(@Valid @RequestBody UserCreateDTO request) {
        return ApiResult.ok(userService.createUser(request));
    }
}
```

## Service / Convert

```java
public interface UserService {
    PageResult<UserVO> pageUsers(UserQueryDTO query);

    UserVO getUser(Long userId);

    UserVO createUser(UserCreateDTO request);
}

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Override
    public PageResult<UserVO> pageUsers(UserQueryDTO query) {
        IPage<User> page = userMapper.selectPage(
                new Page<>(query.getPageNo(), query.getPageSize()),
                Wrappers.<User>lambdaQuery()
                        .like(StrUtil.isNotBlank(query.getUsername()), User::getUsername, query.getUsername())
        );
        return PageResult.of(page, UserConvert::toVO);
    }

    @Override
    public UserVO getUser(Long userId) {
        User user = userMapper.selectById(userId);
        ApiResultAssert.notNull(user, ErrorCode.USER_NOT_FOUND);
        return UserConvert.toVO(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserVO createUser(UserCreateDTO request) {
        boolean exists = userMapper.exists(
                Wrappers.<User>lambdaQuery().eq(User::getMobile, request.getMobile())
        );
        ApiResultAssert.isFalse(exists, ErrorCode.USER_MOBILE_EXISTS);
        User user = UserConvert.toEntity(request);
        userMapper.insert(user);
        return UserConvert.toVO(user);
    }
}

public final class UserConvert {

    private UserConvert() {
    }

    public static User toEntity(UserCreateDTO request) {
        User user = new User();
        user.setUsername(request.getUsername());
        user.setMobile(request.getMobile());
        return user;
    }

    public static UserVO toVO(User user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setMobile(user.getMobile());
        return vo;
    }
}
```

## application.yml

```yaml
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  configuration:
    map-underscore-to-camel-case: true
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0

springdoc:
  api-docs:
    enabled: true
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
```
