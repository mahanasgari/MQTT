interface StateBadgeProps {
  connectivity: string;
}

export function StateBadge({ connectivity }: StateBadgeProps) {
  const online = connectivity === "online";
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ${
        online
          ? "bg-green-50 text-green-700 ring-1 ring-green-600/20"
          : "bg-gray-50 text-gray-500 ring-1 ring-gray-300"
      }`}
    >
      <span
        className={`h-1.5 w-1.5 rounded-full ${
          online ? "bg-green-500" : "bg-gray-300"
        }`}
      />
      {online ? "Online" : "Offline"}
    </span>
  );
}

interface PowerBadgeProps {
  power: string;
}

export function PowerBadge({ power }: PowerBadgeProps) {
  const on = power === "on";
  return (
    <span
      className={`inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium ${
        on
          ? "bg-yellow-100 text-yellow-800 ring-1 ring-yellow-600/20"
          : "bg-gray-100 text-gray-500 ring-1 ring-gray-300"
      }`}
    >
      {on ? "ON" : "OFF"}
    </span>
  );
}
