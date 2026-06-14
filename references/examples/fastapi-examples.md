# FastAPI Examples

仅在初始化项目、补齐基础设施、或需要完整样例时读取。项目已有实现优先；如项目无统一实现，优先按本文模板保持一致。

## 推荐目录

```text
app
├── api/v1/endpoints/user.py
├── common/asserts.py
├── common/pagination.py
├── common/result.py
├── core/exceptions.py
├── core/exception_handlers.py
├── db/session.py
└── modules/user
    ├── converter.py
    ├── model.py
    ├── repository.py
    ├── schema.py
    └── service.py
```

## ApiResult

```python
from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class ApiResult(BaseModel, Generic[T]):
    code: int = Field(..., description="业务状态码")
    msg: str = Field(..., description="响应消息")
    data: T | None = Field(default=None, description="响应数据")

    @classmethod
    def ok(cls, data: T | None = None, msg: str = "操作成功") -> "ApiResult[T]":
        return cls(code=200, msg=msg, data=data)

    @classmethod
    def error(cls, code: int = 500, msg: str = "系统繁忙，请稍后重试") -> "ApiResult[None]":
        return cls(code=code, msg=msg, data=None)
```

## PageResult

```python
from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class PageResult(BaseModel, Generic[T]):
    page_no: int = Field(..., description="当前页码")
    page_size: int = Field(..., description="每页数量")
    total: int = Field(..., description="总记录数")
    pages: int = Field(..., description="总页数")
    records: list[T] = Field(default_factory=list, description="当前页数据")

    @classmethod
    def of(cls, records: list[T], total: int, page_no: int, page_size: int) -> "PageResult[T]":
        pages = (total + page_size - 1) // page_size if page_size > 0 else 0
        return cls(page_no=page_no, page_size=page_size, total=total, pages=pages, records=records)
```

## ErrorCode / BusinessException / ApiAssert

```python
from enum import Enum
from typing import Any


class ErrorCode(Enum):
    SUCCESS = (200, "操作成功")
    PARAM_ERROR = (400, "请求参数错误")
    UNAUTHORIZED = (401, "用户未登录")
    FORBIDDEN = (403, "无权限访问")
    NOT_FOUND = (404, "资源不存在")
    CONFLICT = (409, "资源冲突")
    BUSINESS_ERROR = (1000, "业务处理失败")
    SYSTEM_ERROR = (500, "系统繁忙，请稍后重试")
    USER_NOT_FOUND = (2001, "用户不存在")
    USER_MOBILE_EXISTS = (2002, "手机号已存在")

    def __init__(self, code: int, msg: str) -> None:
        self.code = code
        self.msg = msg


class BusinessException(Exception):
    def __init__(self, code: int = 1000, msg: str = "业务处理失败", http_status: int = 400) -> None:
        self.code = code
        self.msg = msg
        self.http_status = http_status
        super().__init__(msg)

    @classmethod
    def from_error_code(cls, error_code: ErrorCode, http_status: int = 400) -> "BusinessException":
        return cls(code=error_code.code, msg=error_code.msg, http_status=http_status)


class ApiAssert:
    @staticmethod
    def is_true(expression: bool, error_code: ErrorCode = ErrorCode.BUSINESS_ERROR) -> None:
        if not expression:
            raise BusinessException.from_error_code(error_code)

    @staticmethod
    def is_false(expression: bool, error_code: ErrorCode = ErrorCode.BUSINESS_ERROR) -> None:
        if expression:
            raise BusinessException.from_error_code(error_code)

    @staticmethod
    def not_none(value: Any, error_code: ErrorCode = ErrorCode.NOT_FOUND) -> None:
        if value is None:
            raise BusinessException.from_error_code(error_code, http_status=404)
```

## Exception Handlers

```python
import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette import status

from app.common.result import ApiResult
from app.core.exceptions import BusinessException

logger = logging.getLogger(__name__)


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(BusinessException)
    async def handle_business_exception(request: Request, exc: BusinessException) -> JSONResponse:
        return JSONResponse(
            status_code=exc.http_status,
            content=ApiResult.error(code=exc.code, msg=exc.msg).model_dump(),
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_exception(request: Request, exc: RequestValidationError) -> JSONResponse:
        message = "请求参数校验失败"
        if exc.errors():
            message = exc.errors()[0].get("msg", message)
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content=ApiResult.error(code=400, msg=message).model_dump(),
        )

    @app.exception_handler(Exception)
    async def handle_exception(request: Request, exc: Exception) -> JSONResponse:
        logger.exception("system exception")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content=ApiResult.error(code=500, msg="系统繁忙，请稍后重试").model_dump(),
        )
```

## Schema

```python
from pydantic import BaseModel, ConfigDict, Field


class UserCreateRequest(BaseModel):
    username: str = Field(..., min_length=1, max_length=32, description="用户名")
    mobile: str = Field(..., pattern=r"^1[3-9]\d{9}$", description="手机号")


class UserQueryRequest(BaseModel):
    page_no: int = Field(default=1, ge=1, description="页码，从1开始")
    page_size: int = Field(default=10, ge=1, le=100, description="每页数量，最大100")
    username: str | None = Field(default=None, description="用户名，支持模糊查询")


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="用户ID")
    username: str = Field(..., description="用户名")
    mobile: str = Field(..., description="手机号")
```

## Model / Repository

```python
from datetime import datetime

from sqlalchemy import DateTime, Integer, String, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class User(Base):
    __tablename__ = "sys_user"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(32), nullable=False, comment="用户名")
    mobile: Mapped[str] = mapped_column(String(20), nullable=False, comment="手机号")
    create_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    update_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    deleted: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class UserRepository:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_id(self, user_id: int) -> User | None:
        stmt = select(User).where(User.id == user_id, User.deleted == 0)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def page_users(self, page_no: int, page_size: int) -> tuple[list[User], int]:
        offset = (page_no - 1) * page_size
        total_stmt = select(func.count()).select_from(User).where(User.deleted == 0)
        data_stmt = (
            select(User)
            .where(User.deleted == 0)
            .order_by(User.id.desc())
            .offset(offset)
            .limit(page_size)
        )
        total_result = await self.db.execute(total_stmt)
        data_result = await self.db.execute(data_stmt)
        return list(data_result.scalars().all()), total_result.scalar_one()

    async def exists_by_mobile(self, mobile: str) -> bool:
        stmt = select(func.count()).select_from(User).where(User.mobile == mobile, User.deleted == 0)
        result = await self.db.execute(stmt)
        return result.scalar_one() > 0
```

## Converter / Service

```python
class UserConverter:
    @staticmethod
    def create_request_to_model(request: UserCreateRequest) -> User:
        return User(username=request.username, mobile=request.mobile)

    @staticmethod
    def model_to_response(user: User) -> UserResponse:
        return UserResponse(id=user.id, username=user.username, mobile=user.mobile)


class UserService:
    """用户业务服务。

    负责用户查询、创建和用户领域规则校验，不处理 HTTP 入参和响应封装。
    """

    def __init__(self, db: AsyncSession) -> None:
        self.db = db
        self.repository = UserRepository(db)

    async def page_users(self, page_no: int, page_size: int) -> PageResult[UserResponse]:
        """分页查询用户列表。

        Args:
            page_no: 页码，从 1 开始。
            page_size: 每页数量。

        Returns:
            用户分页数据，查询结果为空时返回空 records。
        """
        users, total = await self.repository.page_users(page_no=page_no, page_size=page_size)
        records = [UserConverter.model_to_response(user) for user in users]
        return PageResult.of(records=records, total=total, page_no=page_no, page_size=page_size)

    async def get_user(self, user_id: int) -> UserResponse:
        """查询用户详情。

        Args:
            user_id: 用户 ID。

        Returns:
            用户详情。

        Raises:
            BusinessException: 用户不存在时抛出 USER_NOT_FOUND。
        """
        user = await self.repository.get_by_id(user_id)
        ApiAssert.not_none(user, ErrorCode.USER_NOT_FOUND)
        return UserConverter.model_to_response(user)

    async def create_user(self, request: UserCreateRequest) -> UserResponse:
        """创建用户。

        Args:
            request: 创建用户请求。

        Returns:
            创建后的用户信息。

        Raises:
            BusinessException: 手机号已存在时抛出 USER_MOBILE_EXISTS。
        """
        try:
            exists = await self.repository.exists_by_mobile(request.mobile)
            ApiAssert.is_false(exists, ErrorCode.USER_MOBILE_EXISTS)
            user = UserConverter.create_request_to_model(request)
            self.db.add(user)
            await self.db.commit()
            await self.db.refresh(user)
            return UserConverter.model_to_response(user)
        except Exception:
            await self.db.rollback()
            raise
```

## Router

```python
from fastapi import APIRouter, Depends, Path, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.pagination import PageResult
from app.common.result import ApiResult
from app.db.session import get_db
from app.modules.user.schema import UserCreateRequest, UserResponse
from app.modules.user.service import UserService

router = APIRouter(prefix="/users", tags=["用户管理"])


@router.get("", response_model=ApiResult[PageResult[UserResponse]], summary="分页查询用户")
async def page_users(
    page_no: int = Query(default=1, ge=1, description="页码，从1开始"),
    page_size: int = Query(default=10, ge=1, le=100, description="每页数量，最大100"),
    db: AsyncSession = Depends(get_db),
) -> ApiResult[PageResult[UserResponse]]:
    service = UserService(db)
    return ApiResult.ok(await service.page_users(page_no=page_no, page_size=page_size))


@router.get("/{user_id}", response_model=ApiResult[UserResponse], summary="查询用户详情")
async def get_user(
    user_id: int = Path(..., ge=1, description="用户ID"),
    db: AsyncSession = Depends(get_db),
) -> ApiResult[UserResponse]:
    service = UserService(db)
    return ApiResult.ok(await service.get_user(user_id))


@router.post("", response_model=ApiResult[UserResponse], summary="创建用户")
async def create_user(
    request: UserCreateRequest,
    db: AsyncSession = Depends(get_db),
) -> ApiResult[UserResponse]:
    service = UserService(db)
    return ApiResult.ok(await service.create_user(request))
```
