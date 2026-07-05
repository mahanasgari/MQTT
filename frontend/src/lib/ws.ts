"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { useAuth } from "./auth";

const BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/v1";
const WS_BASE = BASE_URL.replace(/^http/, "ws");

interface UseWebSocketResult {
  connected: boolean;
  states: Record<string, Record<string, unknown>>;
}

export function useDeviceWebSocket(
  deviceIds: string[],
): UseWebSocketResult {
  const { user } = useAuth();
  const [connected, setConnected] = useState(false);
  const [states, setStates] = useState<Record<string, Record<string, unknown>>>(
    {},
  );
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const deviceIdsRef = useRef(deviceIds);

  useEffect(() => {
    deviceIdsRef.current = deviceIds;
  }, [deviceIds]);

  const disconnect = useCallback(() => {
    if (reconnectRef.current) {
      clearTimeout(reconnectRef.current);
      reconnectRef.current = null;
    }
    if (wsRef.current) {
      wsRef.current.onclose = null;
      wsRef.current.close();
      wsRef.current = null;
    }
  }, []);

  const connectRef = useRef<(() => void) | null>(null);

  const connect = useCallback(() => {
    const token = localStorage.getItem("access_token");
    if (!token || deviceIdsRef.current.length === 0) return;

    disconnect();

    const ws = new WebSocket(`${WS_BASE}/ws?token=${token}`);
    wsRef.current = ws;

    ws.onopen = () => {
      setConnected(true);
      const ids = deviceIdsRef.current;
      if (ids.length > 0) {
        ws.send(
          JSON.stringify({ type: "subscribe", device_ids: ids }),
        );
      }
    };

    ws.onmessage = (event) => {
      try {
        const msg = JSON.parse(event.data);
        if (msg.type === "state_update" && msg.device_id) {
          setStates((prev) => ({
            ...prev,
            [msg.device_id]: { ...(prev[msg.device_id] || {}), ...msg.data },
          }));
        } else if (msg.type === "connectivity_change" && msg.device_id) {
          setStates((prev) => ({
            ...prev,
            [msg.device_id]: { ...(prev[msg.device_id] || {}), ...msg.data },
          }));
        }
      } catch {
        /* ignore */
      }
    };

    ws.onclose = () => {
      setConnected(false);
      reconnectRef.current = setTimeout(() => connectRef.current?.(), 3000);
    };

    ws.onerror = () => {
      ws.close();
    };
  }, [disconnect]);

  useEffect(() => {
    connectRef.current = connect;
  }, [connect]);

  const deviceIdsKey = deviceIds.join(",");

  useEffect(() => {
    if (!user || deviceIds.length === 0) return;
    connect();
    return () => disconnect();
  }, [user, deviceIdsKey, deviceIds.length, connect, disconnect]);

  return { connected, states };
}
