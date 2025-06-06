# 📦 Guía de Despliegue de la Infraestructura E-commerce en AWS (CloudFormation)

---

## 📁 Archivos Utilizados

La infraestructura está dividida en 5 stacks independientes, cada uno representado por un archivo `.yml`, y un archivo de parámetros general:

| Archivo          | Descripción breve                                                                      |
| ---------------- | -------------------------------------------------------------------------------------- |
| `network.yml`    | Define toda la infraestructura de red base                                             |
| `security.yml`   | Crea los grupos de seguridad necesarios                                                |
| `database.yml`   | Despliega la base de datos MySQL                                                       |
| `compute.yml`    | Configura instancias, ALB y Auto Scaling                                               |
| `monitoring.yml` | Añade monitoreo, alertas y auditoría                                                   |
| `params.json`    | Contiene parámetros reutilizables como tipo de instancia, ambiente, credenciales, etc. |
| `deploy-all.sh`  | Script que ejecuta todos los stacks en orden, mostrando el progreso                    |

---

## 🛠️ Descripción General de Cada Stack

### 1. `network.yml`

Crea la red base del sistema:

* VPC principal
* Subredes públicas, privadas y para base de datos
* Internet Gateway, NAT Gateway
* Tablas de enrutamiento y asociaciones

➡️ **Exporta** valores como VPC ID y Subnet IDs que serán utilizados por los demás stacks.
📌 **Debe desplegarse primero.**

---

### 2. `security.yml`

Define los Security Groups para:

* ALB (HTTP/HTTPS)
* Web Servers (Node.js + Nginx)
* Bastion Host (SSH)
* Base de datos MySQL

➡️ Usa `!ImportValue` para obtener la VPC desde `network.yml`.
📌 **Se despliega inmediatamente después del stack de red.**

---

### 3. `database.yml`

Despliega la instancia **MySQL (RDS)**:

* Instancia privada
* DB Subnet Group
* Backup, seguridad y configuración

➡️ Depende de:

* Subredes del stack de red
* Security Group del stack de seguridad

📌 **Requiere que `network.yml` y `security.yml` estén desplegados.**

---

### 4. `compute.yml`

Contiene toda la lógica de cómputo:

* Bastion Host (EC2 t2.micro)
* Launch Template con UserData:

  * Instala Node.js y Nginx
  * Clona repositorios del frontend y backend
  * Levanta servicios
* Auto Scaling Group
* Application Load Balancer
* Target Group para balancear tráfico

➡️ Depende de:

* VPC/Subnets (`network.yml`)
* Security Groups (`security.yml`)
* DB endpoint (`database.yml`)

📌 **Se despliega cuarto.**

---

### 5. `monitoring.yml`

Agrega capacidades de monitoreo y auditoría:

* Alarmas de CloudWatch (CPU alta/baja)
* Políticas de escalado automático
* SNS Topic para alertas por correo
* CloudTrail con bucket S3 privado para logs

➡️ Depende del Auto Scaling Group de `compute.yml`.
📌 **Es el último stack en desplegarse.**

---

## 🚀 Flujo de Despliegue (`deploy-all.sh`)

Este script automatiza el despliegue en el siguiente orden estricto:

1. `ecommerce-network`
2. `ecommerce-security`
3. `ecommerce-database`
4. `ecommerce-compute`
5. `ecommerce-monitoring`

🔧 Usa `aws cloudformation deploy` con los parámetros definidos en `params.json`, y espera que cada stack termine antes de continuar.

---

## 📈 Ventajas de la Estructura Modular

✅ **Reutilizable**: puedes actualizar un stack sin tocar los otros.
✅ **Escalable**: puedes agregar más stacks (e.g., S3, Lambda, etc.).
✅ **Debuggable**: si algo falla, sabes exactamente dónde está el problema.
✅ **Evita duplicación**: la lógica de red o seguridad se escribe una sola vez.

---

## ✉️ Recomendaciones

* Comenzar siempre con `network.yml`
* Verificar `exports` con `aws cloudformation list-exports`
* Tener cuidado con los nombres de `Export/Import`
* Asegurarse de que los `Stack Names` y `Export Names` sean únicos por ambiente (`dev`, `prod`, etc.)

---

## 🌟 Resultado Esperado

Al finalizar el despliegue, deberías tener:

✔️ Una aplicación E-commerce Node.js corriendo tras un ALB
✔️ Frontend y backend funcionales
✔️ Monitoreo y escalado activo por carga
✔️ Base de datos MySQL privada y segura
✔️ Logs de auditoría almacenados en CloudTrail (S3)

Si deseas agregar nuevos ambientes (dev, staging, prod), simplemente cambia el valor de `"Environment"` en `params.json`.

[Link repositorio frontend](https://github.com/DavidMolta18/Ecommerce-frontend.git)

[Link repositorio backend](https://github.com/DavidMolta18/Ecommerce-backend.git)

