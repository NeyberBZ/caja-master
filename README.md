# CajaMaster

Dashboard de cuadre de caja, ingresos y egresos construido con Astro, TypeScript, Tailwind CSS y Supabase.

## Estado inicial

Este scaffold es una aplicación nueva; no reemplaza archivos de otro proyecto. La referencia visual es el prototipo `dashboard_de_cuadre_de_caja.html`.

## Requisitos

- Node.js 20.19+ o 22.12+
- pnpm
- Proyecto Supabase con acceso al SQL Editor
- Clave publicable de Supabase (o clave heredada `anon`)

## Desarrollo

```bash
pnpm install
cp .env.example .env
pnpm dev
```

Completa las variables de `.env` con la URL y la clave publicable de tu proyecto. Nunca pongas `service_role` ni claves `sb_secret_...` en variables `PUBLIC_*`.

## Base de datos

La migración `supabase/migrations/202610200001_caja_master.sql` crea únicamente tablas con prefijo `caja_`. No se ejecutó automáticamente en Supabase. Revísala y ejecútala solo después de confirmar que estás conectado al proyecto correcto.

## Alcance de este scaffold

- Dashboard visual responsive.
- Apertura de caja con fondo inicial.
- Registro de ventas y egresos en el cliente.
- Arqueo y cálculo de diferencia.
- Conector Supabase con estado de conexión.
- Exportación de reporte Markdown local.
- Esquema inicial protegido con RLS.

**Importante:** antes de habilitar datos reales para varios usuarios, configura Supabase Auth y adapta las políticas de acceso. La migración inicial habilita RLS y mantiene el acceso de escritura cerrado por defecto.
