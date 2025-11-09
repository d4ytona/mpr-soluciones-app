# Historial de Desarrollo — MPR Soluciones

## 2025 — Inicio del Proyecto

### 1. Creación del repositorio

- Se creó repositorio vacío en GitHub.
- Se clonó en el entorno WSL.

### 2. Estructura inicial del proyecto

- Se creó un nuevo proyecto usando:
  ```
  npx create-expo-app@latest --template
  ```
- Se eligió plantilla **"Blank (TypeScript)"**.
- Se evitó crear carpetas adicionales ejecutando el comando desde la carpeta del repo.

### 3. Configuración base de Expo

- Se instalaron las dependencias para soporte web:
  ```
  npx expo install react-dom react-native-web
  ```

### 4. Configuración para correr en WSL

- Al utilizar WSL como entorno de trabajo, para poder utilizar Expo Go desde el móvil necesitamos:
  ```
  npx expo start --tunnel
  ```

### 5. Documentación inicial

- Se escribió README inicial con finalidad del proyecto.
- Se estableció que App + Web estarán dentro del mismo monorepo Expo.

---

### Próximos pasos sugeridos

- Configurar Supabase + variables de entorno.
- Configurar Expo Router desde cero.
- Crear estructura inicial `(auth)` y `(tabs)`.
- Implementar login real con Supabase.
