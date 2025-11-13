# Payment Blocks API

Сервис для блокировки исходящих платежей юрлиц: создать/снять блокировку, проверить статус, вести историю и отличать типы блокировок (fraud vs wrong_details).

```
openapi/openapi.yaml    # спецификация OAS 3.0
db/migrations/001_init.sql
docs/README.md          # этот файл
examples/curl.md        # примеры запросов
docker-compose.yml      # Swagger UI + mock (Prism)
```

# Запуск

```
docker compose up -d
```
Swagger UI: http://localhost:8080
Mock API: http://localhost:4010

# Основные сценарии

1.	Заблокировать платежи клиента
POST /v1/clients/{clientId}/payment-blocks
Тело: { type: fraud|wrong_details|other, reason, expiresAt? }
Возвращает созданную запись блокировки.
2.	Проверить, заблокирован ли клиент
GET /v1/clients/{clientId}/payment-blocks/status
Ответ: { blocked: boolean, block?: PaymentBlock }
3.	Разблокировать клиента (закрыть блокировку)
POST /v1/clients/{clientId}/payment-blocks/{blockId}/release
Тело: { reason } - помечает блокировку как снятую.
4.	История блокировок клиента
GET /v1/clients/{clientId}/payment-blocks?active=true|false
Список всех/только активных блокировок.

# Модель данных (PostgreSQL)

Схема в db/migrations/001_init.sql. Ключевые поля таблицы payment_block:
- id uuid PK, client_id uuid
- type enum('fraud','wrong_details','other'), reason text
- created_at/by, expires_at
- released_at/by, release_reason

# Примеры запросов



# Ошибки

Создать блокировку:

```
curl -X POST http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks \
  -H "Authorization: Bearer demo" \
  -H "Idempotency-Key: k1" \
  -H "Content-Type: application/json" \
  -d '{"type":"wrong_details","reason":"IBAN mismatch","expiresAt":null}'
```

Проверить статус:

```
curl http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks/status \
  -H "Authorization: Bearer demo"
```

Снять блокировку:

```
curl -X POST http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks/00000000-0000-0000-0000-000000000000/release \
  -H "Authorization: Bearer demo" \
  -H "Content-Type: application/json" \
  -d '{"reason":"verified details"}'
```

История:

```
curl "http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks?active=true" \
  -H "Authorization: Bearer demo"
```


- 400 Bad Request — нарушение схемы тела/параметров
- 401 Unauthorized — нет/неверный токен
- 403 Forbidden — нет прав
- 404 Not Found — клиент/блокировка не найдены
- 409 Conflict — уже есть активная блокировка (при создании)
- 422 Unprocessable Entity — попытка разблокировать неактивную
- 500/503 — внутренняя ошибка/недоступность зависимостей