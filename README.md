# WhatsApp Interactive User Registration - Setup Guide

## 📋 Descripción del Workflow

Este workflow de n8n maneja un proceso completo de registro de usuarios a través de WhatsApp con los siguientes pasos:



### Workflow


1. **Verificación de usuario existente**: Comprueba si el número ya está registrado
2. **Registro paso a paso**:
   - Solicita nombre completo
   - Solicita email con validación
   - Solicita confirmación de datos
3. **Creación de cuenta**: Inserta el usuario en la base de datos
4. **Limpieza**: Elimina datos temporales del proceso

## 🗄️ Tablas de Base de Datos Requeridas

### Tabla `users` (Usuarios permanentes)
```sql
CREATE TABLE users (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registration_date` datetime NOT NULL,
  `status` enum('active','inactive','pending') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabla `user_registration` (Datos temporales del proceso)
```sql
CREATE TABLE user_registration (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_step` enum('start','name','email','confirm') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'name',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## ⚙️ Configuración Necesaria

### 1. Credenciales de WhatsApp Business
Necesitas configurar las credenciales de WhatsApp Business en n8n:
- **Access Token**: Token de acceso de Facebook/Meta
- **Phone Number ID**: ID del número de teléfono de WhatsApp Business
- **Verify Token**: Token para verificar el webhook

### 2. Configuración de Base de Datos MySQL
Configura una conexión MySQL en n8n con:
- Host de la base de datos
- Puerto (normalmente 3306)
- Nombre de la base de datos
- Usuario y contraseña

### 3. Webhook de WhatsApp
1. En Facebook Developers, configura el webhook URL de n8n (Menu Lateral => Whatsapp => Configuracion)
    - En el elemento whatsapp message trigger, esta la url POST que deberás elegir.
2. Suscríbete a los eventos `messages`
3. Verifica el webhook con el token configurado  (Debes tener el worflow activado para validarlo y la url deberia ser accesible publicamente)

## 🔄 Flujo del Proceso

### Estado Inicial
- Usuario envía cualquier mensaje → **Inicia verificación**

### Flujos Principales

#### Usuario Existente
```
Mensaje → Verificar Usuario → ✅ Existe → "¡Hola [nombre]! Ya tienes cuenta..."
```

#### Usuario Nuevo - Registro Completo
```
Mensaje → Verificar Usuario → ❌ No existe → Verificar Paso de Registro

├── Paso: start → Inicializar registro → "¡Hola! Compárteme tu nombre"
├── Paso: name → Guardar nombre → "Perfecto [nombre]! Tu email?"
├── Paso: email → Validar email → ✅ Válido → "Revisa tus datos..."
│                              → ❌ Inválido → "Formato incorrecto..."
└── Paso: confirm → Procesar confirmación
    ├── "SÍ" → Crear cuenta → Limpiar datos temporales → "¡Registro exitoso!"
    └── "NO" → Reiniciar proceso → "Registro reiniciado..."
```

## 🎯 Características del Workflow

### ✅ Funcionalidades Implementadas
- **Detección de usuarios existentes**: Evita registros duplicados
- **Proceso paso a paso**: Mantiene el estado del registro
- **Validación de email**: Verifica formato válido con regex
- **Confirmación de datos**: Permite revisar antes de confirmar
- **Reinicio de proceso**: Permite comenzar de nuevo si hay errores
- **Limpieza automática**: Elimina datos temporales tras registro exitoso
- **Mensajes en español**: Interfaz amigable en español con emojis

### 🔧 Nodos Utilizados
- **WhatsApp Trigger**: Recibe mensajes de WhatsApp
- **Webhook Trigger**: Recibe mensajes de WhatsApp de manera manual enviados por ejemplo con postman para valiadar el flow localmente.
- **MySQL**: Gestiona base de datos (consultas, inserts, updates)
- **Switch**: Lógica condicional para diferentes estados
- **WhatsApp Business Cloud**: Envía respuestas automáticas

## 🚀 Activación del Workflow

1. **Importar workflow**: "Workflow-Whatsapp_Registration_User"
2. **Configurar credenciales**: WhatsApp Business y MySQL
3. **Crear tablas**: Ejecutar los scripts SQL proporcionados
4. **Activar workflow**: Cambiar estado a "Active" en n8n
5. **Probar**: Enviar mensaje de WhatsApp al número configurado

## 🔍 Testing y Depuración

### Casos de Prueba
1. **Usuario nuevo completo**: Probar todo el flujo de registro
2. **Usuario existente**: Verificar mensaje de bienvenida
3. **Email inválido**: Probar validación de formato
4. **Proceso interrumpido**: Verificar continuidad del estado
5. **Reinicio manual**: Probar respuesta "NO" en confirmación


## 📊 Ejemplo de Conversación

```
👤 Usuario: Hola
🤖 Bot: ¡Hola! 👋 Bienvenido al registro de nuestra plataforma.
      Para comenzar, por favor compárteme tu nombre completo.

👤 Usuario: Juan Pérez
🤖 Bot: Perfecto, Juan Pérez! 📧
      Ahora necesito tu dirección de correo electrónico.

👤 Usuario: juan.perez@email.com
🤖 Bot: Excelente! 📋 Por favor revisa tus datos:
      👤 Nombre: Juan Pérez
      📧 Email: juan.perez@email.com
      📱 Teléfono: +1234567890
      
      ¿Los datos son correctos?
      ✅ *SÍ* para confirmar
      ❌ *NO* para reiniciar

👤 Usuario: SÍ
🤖 Bot: 🎉 ¡Registro completado exitosamente!
      Bienvenido/a Juan Pérez a nuestra plataforma.
      
      Tus credenciales:
      👤 Usuario: juan.perez@email.com
      
      Ya puedes acceder a todos nuestros servicios. ¡Gracias por registrarte! 🚀
```



## Documentacion:

### Facebook Whatsapp: 
    https://developers.facebook.com/docs/whatsapp/cloud-api/get-started


### n8n
    - Templates: https://n8n.io/workflows/
    - Whatsapp Templates: https://n8n.io/workflows/?integrations=WhatsApp
