# ✅ Статус деплоя BaseRelayer

## 🎉 Контракты задеплоены!

### Base Sepolia (Testnet)

✅ **Forwarder**
- Адрес: `0x0359AF56e8B9E8f3845dDD9a785ffcdc6744f698`
- Статус: Задеплоен и верифицирован
- Explorer: https://sepolia.basescan.org/address/0x0359AF56e8B9E8f3845dDD9a785ffcdc6744f698

✅ **RelayerHub**
- Адрес: `0xdbA826B618744d9f4f10bF70b11c3374fDd85406`
- Статус: Задеплоен и верифицирован
- Explorer: https://sepolia.basescan.org/address/0xdbA826B618744d9f4f10bF70b11c3374fDd85406

## 📝 Что нужно сделать дальше

### 1. Настроить Relayer

Создайте `relayer/.env` (если еще не создан):
```bash
PORT=3002
FORWARDER_ADDRESS=0x0359AF56e8B9E8f3845dDD9a785ffcdc6744f698
RELAYER_PRIVATE_KEY=ваш_приватный_ключ_для_релейера
RPC_URL=https://sepolia.base.org
RELAYER_HUB_ADDRESS=0xdbA826B618744d9f4f10bF70b11c3374fDd85406
```

**Важно:** `RELAYER_PRIVATE_KEY` должен быть другим ключом (не тем, что использовался для деплоя), и у этого кошелька должен быть Base Sepolia ETH для оплаты газа.

### 2. Настроить Backend

Создайте `backend/.env` (если еще не создан):
```bash
PORT=3001
RELAYER_URL=http://localhost:3002
FORWARDER_ADDRESS=0x0359AF56e8B9E8f3845dDD9a785ffcdc6744f698
RELAYER_HUB_ADDRESS=0xdbA826B618744d9f4f10bF70b11c3374fDd85406
RPC_URL=https://sepolia.base.org
```

### 3. Настроить Frontend

Создайте `frontend/.env.local`:
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_RELAYER_URL=http://localhost:3002
NEXT_PUBLIC_FORWARDER_ADDRESS=0x0359AF56e8B9E8f3845dDD9a785ffcdc6744f698
NEXT_PUBLIC_RELAYER_HUB_ADDRESS=0xdbA826B618744d9f4f10bF70b11c3374fDd85406
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=ваш_walletconnect_project_id
NEXT_PUBLIC_CHAIN_ID=84532
```

**Получить WalletConnect Project ID:** https://cloud.walletconnect.com

### 4. Запустить локально

```bash
# Установить зависимости
npm run install:all

# Запустить все сервисы
./scripts/start-dev.sh
```

Или по отдельности:
- `cd relayer && npm run dev` (порт 3002)
- `cd backend && npm run dev` (порт 3001)
- `cd frontend && npm run dev` (порт 3000)

### 5. Деплой Frontend на Vercel

```bash
cd frontend
npm i -g vercel
vercel
```

После деплоя добавьте переменные окружения в Vercel Dashboard (Settings → Environment Variables).

## 🔗 Полезные ссылки

- [Deployed Addresses](./DEPLOYED_ADDRESSES.md)
- [Quick Start Guide](./QUICK_START.md)
- [Deployment Guide](./DEPLOYMENT.md)
- [Base Sepolia Explorer](https://sepolia.basescan.org)

---

**Дата деплоя:** 2025-01-27  
**Сеть:** Base Sepolia (Chain ID: 84532)

