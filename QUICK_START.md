# 🚀 Quick Start Guide

Быстрый старт для BaseRelayer.

## 📋 Что нужно перед началом

1. **Foundry** - установлен и работает
2. **Node.js ≥18.x** - установлен
3. **Base Sepolia ETH** - для тестирования (получить на [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet))
4. **Basescan API Key** - для верификации контрактов (получить на [Basescan](https://basescan.org/apis))
5. **WalletConnect Project ID** - для фронтенда (получить на [WalletConnect Cloud](https://cloud.walletconnect.com))

## ⚡ Быстрый старт (3 шага)

### Шаг 1: Установка зависимостей

```bash
npm run install:all
```

### Шаг 2: Настройка переменных окружения

#### Контракты

```bash
cd contracts
cp .env.example .env
# Отредактируйте .env и добавьте:
# PRIVATE_KEY=ваш_приватный_ключ
# BASESCAN_API_KEY=ваш_api_ключ
```

#### Фронтенд

```bash
cd ../frontend
cp .env.example .env.local
# Отредактируйте .env.local и добавьте:
# NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=ваш_project_id
```

### Шаг 3: Деплой контрактов

```bash
# Вернитесь в корень проекта
cd ../..

# Деплой на Base Sepolia
./scripts/deploy-sepolia.sh
```

После деплоя сохраните адреса контрактов и обновите `.env` файлы в `relayer`, `backend`, и `frontend`.

## 🏃 Запуск локально

### Вариант 1: Все сервисы сразу

```bash
./scripts/start-dev.sh
```

### Вариант 2: По отдельности

**Терминал 1 - Relayer:**
```bash
cd relayer
npm run dev
```

**Терминал 2 - Backend:**
```bash
cd backend
npm run dev
```

**Терминал 3 - Frontend:**
```bash
cd frontend
npm run dev
```

Откройте http://localhost:3000 в браузере.

## 📦 Деплой фронтенда на Vercel

### Через CLI

```bash
# Установите Vercel CLI (если еще не установлен)
npm i -g vercel

# Перейдите в папку frontend
cd frontend

# Запустите деплой
vercel
```

Следуйте инструкциям:
- Set up and deploy? **Yes**
- Which scope? Выберите ваш аккаунт
- Link to existing project? **No**
- Project name? **base-relayer**
- Directory? **./**
- Override settings? **No**

### Настройка переменных окружения в Vercel

1. Откройте [Vercel Dashboard](https://vercel.com/dashboard)
2. Выберите проект `base-relayer`
3. Перейдите в Settings → Environment Variables
4. Добавьте следующие переменные:

```
NEXT_PUBLIC_API_URL=https://your-api-url.com
NEXT_PUBLIC_RELAYER_URL=https://your-relayer-url.com
NEXT_PUBLIC_FORWARDER_ADDRESS=0x... (из деплоя контрактов)
NEXT_PUBLIC_RELAYER_HUB_ADDRESS=0x... (из деплоя контрактов)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_CHAIN_ID=84532
```

5. Передеплойте проект (Redeploy)

## ✅ Чек-лист после деплоя

- [ ] Контракты задеплоены и верифицированы на Basescan
- [ ] Адреса контрактов добавлены в `.env` файлы
- [ ] Relayer запущен и работает
- [ ] Backend API отвечает на `/health`
- [ ] Frontend задеплоен на Vercel
- [ ] Переменные окружения настроены в Vercel
- [ ] Frontend подключается к кошельку
- [ ] README обновлен со ссылками на деплой

## 🐛 Проблемы?

Смотрите [DEPLOYMENT.md](./DEPLOYMENT.md) для подробных инструкций и решения проблем.

## 📚 Дополнительная информация

- [Полное руководство по деплою](./DEPLOYMENT.md)
- [Документация API](./docs/api.md)
- [Интеграция в ваш dApp](./docs/integrations.md)

