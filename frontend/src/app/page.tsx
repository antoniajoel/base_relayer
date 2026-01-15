'use client'

import { useState } from 'react'
import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { ConnectButton } from '@rainbow-me/rainbowkit'

export default function Home() {
  const { address, isConnected } = useAccount()
  const [to, setTo] = useState('')
  const [data, setData] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<string | null>(null)

  const handleRelay = async () => {
    if (!isConnected || !to || !data) {
      alert('Please connect wallet and fill in all fields')
      return
    }

    setLoading(true)
    setResult(null)

    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await fetch(`${apiUrl}/relay`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          request: {
            from: address,
            to,
            value: '0',
            gas: '100000',
            nonce: '0',
            data,
          },
          signature: '0x', // TODO: Sign with wallet
        }),
      })

      const data = await response.json()
      if (data.success) {
        setResult(`Transaction relayed! Hash: ${data.txHash}`)
      } else {
        setResult(`Error: ${data.error}`)
      }
    } catch (error: any) {
      setResult(`Error: ${error.message}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-4">BaseRelayer</h1>
          <p className="text-xl text-gray-400">
            Open-source transaction relayer & meta-tx infrastructure for Base
          </p>
          <div className="mt-4">
            <ConnectButton />
          </div>
        </div>

        <div className="bg-gray-800 rounded-lg p-6 mt-8">
          <h2 className="text-2xl font-semibold mb-4">Playground</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">
                To Address
              </label>
              <input
                type="text"
                value={to}
                onChange={(e) => setTo(e.target.value)}
                placeholder="0x..."
                className="w-full px-4 py-2 bg-gray-700 rounded text-white"
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">
                Data (hex)
              </label>
              <textarea
                value={data}
                onChange={(e) => setData(e.target.value)}
                placeholder="0x..."
                className="w-full px-4 py-2 bg-gray-700 rounded text-white h-32"
              />
            </div>

            <button
              onClick={handleRelay}
              disabled={loading || !isConnected}
              className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 px-6 py-3 rounded font-semibold"
            >
              {loading ? 'Relaying...' : 'Relay Transaction'}
            </button>

            {result && (
              <div className="mt-4 p-4 bg-gray-700 rounded">
                <p className="text-sm">{result}</p>
              </div>
            )}
          </div>
        </div>

        <div className="mt-8 text-center text-gray-400">
          <p>Built for Base | Chain ID: 8453</p>
        </div>
      </div>
    </main>
  )
}

