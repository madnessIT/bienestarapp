# 📱 Bienestar App

Aplicación móvil desarrollada en Flutter orientada a la gestión de servicios médicos, permitiendo a los usuarios agendar citas, consultar información clínica y acceder a funcionalidades relacionadas con su atención de salud.

---

## 🚀 Descripción

**Bienestar App** es una solución móvil que conecta a pacientes con servicios médicos mediante una interfaz intuitiva y funcional. La aplicación consume APIs externas para gestionar información en tiempo real, integrando múltiples módulos dentro de un flujo centralizado.

Este proyecto fue desarrollado como una implementación práctica de consumo de APIs, manejo de estado y construcción de interfaces escalables en Flutter.

---

## 🧩 Funcionalidades principales

* 📅 **Gestión de citas médicas**

  * Selección de fecha
  * Visualización de servicios disponibles
  * Reserva de turnos

* 🏥 **Consulta de servicios médicos**

  * Listado por especialidad y regional
  * Integración dinámica con backend

* 👨‍⚕️ **Selección de médicos**

  * Visualización de profesionales disponibles
  * Filtrado por especialidad

* 🧾 **Prefacturación**

  * Generación de pre-factura
  * Visualización de datos del paciente

* 🔳 **Generación de código QR**

  * Integrado para validación de reservas o pagos

* 🧪 **Consulta de laboratorio**

  * Acceso a resultados clínicos mediante API

---

## 🛠️ Tecnologías utilizadas

* **Flutter**
* **Dart**
* **REST API**
* **Provider (gestión de estado)**
* **HTTP (consumo de servicios)**

---

## 🏗️ Arquitectura

El proyecto sigue una estructura modular basada en separación de responsabilidades:

```
lib/
│
├── pages/              # Pantallas principales
├── providers/          # Gestión de estado (Provider)
├── models/             # Modelos de datos
├── services/           # Consumo de APIs
├── widgets/            # Componentes reutilizables
└── utils/              # Funciones auxiliares
```

---

## ⚙️ Instalación y ejecución

1. Clonar el repositorio:

```bash
git clone https://github.com/madnessIT/bienestarapp.git
```

2. Ingresar al proyecto:

```bash
cd bienestarapp
```

3. Instalar dependencias:

```bash
flutter pub get
```

4. Ejecutar la aplicación:

```bash
flutter run
```

---

## 🔌 Configuración

Asegúrate de tener acceso a los endpoints del backend utilizados en el proyecto. Algunos servicios dependen de APIs externas activas.

---

## 📌 Estado del proyecto

🟡 En desarrollo activo
Se continúan mejorando funcionalidades, estructura y experiencia de usuario.

---

## 👨‍💻 Autor

Desarrollado por **Sergio Doynel**

* Experiencia en desarrollo móvil con Flutter
* Integración de APIs y soluciones orientadas a negocio

---

## 📬 Contacto

Para consultas o colaboraciones:
📧 *sergio.doynel@gmail.com*

---

## 📄 Licencia

Este proyecto es de uso privado / demostrativo.
