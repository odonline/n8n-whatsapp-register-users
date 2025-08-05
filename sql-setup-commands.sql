-- ====================================
-- WHATSAPP REGISTRATION SYSTEM - SQL SETUP
-- ====================================

-- Crear base de datos (opcional)
CREATE DATABASE IF NOT EXISTS whatsapp_registration 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE whatsapp_registration;

-- ====================================
-- TABLA DE USUARIOS PERMANENTES
-- ====================================
CREATE TABLE users (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `registration_date` datetime NOT NULL,
  `status` enum('active','inactive','pending') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índices para mejorar rendimiento
    INDEX idx_phone_number (phone_number),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_registration_date (registration_date)
);

-- ====================================
-- TABLA DE REGISTRO TEMPORAL
-- ====================================
CREATE TABLE user_registration (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_step` enum('start','name','email','confirm') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'name',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índice para búsquedas rápidas
    INDEX idx_phone_number (phone_number),
    INDEX idx_current_step (current_step),
    INDEX idx_created_at (created_at)
);

-- ====================================
-- TABLA DE LOG DE MENSAJES (OPCIONAL)
-- ====================================
CREATE TABLE message_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    phone_number VARCHAR(20) NOT NULL,
    message_type ENUM('incoming', 'outgoing') NOT NULL,
    message_content TEXT,
    step_context VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_phone_number (phone_number),
    INDEX idx_created_at (created_at),
    INDEX idx_message_type (message_type)
);


-- ====================================
-- TRIGGERS PARA AUDITORIA (OPCIONAL)
-- ====================================

-- Trigger para loggear creación de usuarios
DELIMITER //
CREATE TRIGGER user_created_log 
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO message_log (phone_number, message_type, message_content, step_context)
    VALUES (NEW.phone_number, 'outgoing', 'Usuario registrado exitosamente', 'registration_complete');
END //
DELIMITER ;

-- ====================================
-- CONFIGURACIÓN DE USUARIO MySQL PARA N8N
-- ====================================

-- Crear usuario específico para n8n (recomendado)
CREATE USER 'n8n_user'@'%' IDENTIFIED BY 'tu_password_seguro';

-- Otorgar permisos necesarios
GRANT SELECT, INSERT, UPDATE, DELETE ON whatsapp_registration.users TO 'n8n_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON whatsapp_registration.user_registration TO 'n8n_user'@'%';
GRANT INSERT ON whatsapp_registration.message_log TO 'n8n_user'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;
