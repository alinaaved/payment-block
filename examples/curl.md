# создать блокировку
curl -X POST http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks \
  -H "Authorization: Bearer demo" -H "Idempotency-Key: k1" \
  -H "Content-Type: application/json" \
  -d '{"type":"wrong_details","reason":"IBAN mismatch","expiresAt":null}'

# проверить статус
curl http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks/status \
  -H "Authorization: Bearer demo"

# снять блокировку
curl -X POST http://localhost:4010/v1/clients/11111111-1111-1111-1111-111111111111/payment-blocks/00000000-0000-0000-0000-000000000000/release \
  -H "Authorization: Bearer demo" -H "Content-Type: application/json" \
  -d '{"reason":"verified details"}'