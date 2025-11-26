# LMAE: Linux Mint Arch Edition
*Una guía completa para crear tu propia distribución basada en Arch Linux*
*con la elegancia de Linux Mint*

## Índice

- [Introducción](#introducción)
- [Capítulo 1: Los Cimientos - Instalando Arch Linux](#capítulo-1-los-cimientos---instalando-arch-linux)
  - [1.1 Preparando el Terreno](#11-preparando-el-terreno)
  - [1.2 Configuración Inicial del Sistema](#12-configuración-inicial-del-sistema)
  - [1.3 El Arte del Particionado](#13-el-arte-del-particionado)
  - [1.4 Optimizando los Mirrors (Opcional pero Recomendado)](#14-optimizando-los-mirrors-opcional-pero-recomendado)
  - [1.5 Instalando el Corazón del Sistema](#15-instalando-el-corazón-del-sistema)
  - [1.6 Configuración del Sistema Recién Instalado](#16-configuración-del-sistema-recén-instalado)
  - [1.7 El Gestor de Arranque GRUB](#17-el-gestor-de-arranque-grub)
  - [1.8 El Primer Arranque](#18-el-primer-arranque)
- [Capítulo 2: La Transformación - Creando el Entorno de Escritorio](#capítulo-2-la-transformación---creando-el-entorno-de-escritorio)
  - [2.1 Preparando el Escenario](#21-preparando-el-escenario)
  - [2.2 Instalando los Componentes Visuales](#22-instalando-los-componentes-visuales)
  - [2.3 Configuraciones Esenciales](#23-configuraciones-esenciales)
  - [2.4 Habilitando el AUR - La Magia de Arch](#24-habilitando-el-aur---la-magia-de-arch)
  - [2.5 La Metamorfosis Visual - Haciendo que se Vea como Linux Mint](#25-la-metamorfosis-visual---haciendo-que-se-vea-como-linux-mint)
  - [2.6 Funcionalidad Adicional](#26-funcionalidad-adicional)
- [Capítulo 3: Completando la Experiencia - Las Aplicaciones de Linux Mint](#capítulo-3-completando-la-experiencia---las-aplicaciones-de-linux-mint)
  - [3.1 Aplicaciones de Productividad y Utilidades](#31-aplicaciones-de-productividad-y-utilidades)
  - [3.2 Aplicaciones de Internet y Comunicación](#32-aplicaciones-de-internet-y-comunicación)
  - [3.3 Suite de Oficina](#33-suite-de-oficina)
  - [3.4 Herramientas de Desarrollo](#34-herramientas-de-desarrollo)
  - [3.5 Multimedia](#35-multimedia)
  - [3.6 Herramientas de Administración](#36-herramientas-de-administración)
  - [3.7 Configuración y Preferencias](#37-configuración-y-preferencias)
  - [3.8 Herramientas del Sistema y Línea de Comandos](#38-herramientas-del-sistema-y-línea-de-comandos)
  - [3.9 Optimizaciones para Laptops (Opcional)](#39-optimizaciones-para-laptops-opcional)
- [Conclusión](#conclusión)
- [Mantenimiento del Sistema](#mantenimiento-del-sistema)

---

## Introducción

Esta guía explica cómo combinar la base sólida y rolling-release
de Arch Linux con el entorno de escritorio Cinnamon y las
aplicaciones de Linux Mint. El resultado es un sistema que mantiene
la flexibilidad de Arch mientras ofrece la experiencia visual y
funcional de Linux Mint.

El proceso se divide en tres etapas principales:
- Instalación de Arch Linux
- Configuración del entorno de escritorio Cinnamon
- Instalación de las aplicaciones características de Linux Mint

Cada sección incluye explicaciones claras de los comandos y
configuraciones necesarias.

# Capítulo 1: Los Cimientos - Instalando Arch Linux

En este capítulo aprenderás a instalar Arch Linux desde cero,
configurando el sistema base que servirá de fundamento para tu LMAE.
Cubriremos desde la preparación del medio de instalación hasta el primer
arranque del sistema.

## 1.1 Preparando el Terreno

### Descargando la imagen de instalación

Descarga la imagen ISO más reciente desde el sitio oficial de Arch Linux
en [https://archlinux.org/download/](https://archlinux.org/download/).
Asegúrate de usar la versión oficial para evitar problemas de seguridad.

### Creando el medio de instalación

Una vez descargada la ISO, grábala en un USB o DVD usando alguna de estas
herramientas:
- **balenaEtcher**: Intuitivo y multiplataforma
- **Rufus**: Rápido y eficiente para Windows
- **Win32 Disk Imager**: Una opción clásica y confiable

### Arrancando desde el medio de instalación

Arranca tu computadora desde el USB o DVD que acabas de crear.
Esto puede requerir cambiar el orden de arranque en la BIOS/UEFI.

## 1.2 Configuración Inicial del Sistema

### Ajustando el teclado a tu idioma

Por defecto, el teclado está configurado en inglés.
Para cambiarlo, primero lista los mapas de teclado disponibles:
```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
```

Luego aplica el que necesites. Por ejemplo, para teclado latinoamericano:
```bash
loadkeys la-latin1
```

> **Nota:** Si usas teclado español de España, usa `es` en lugar de
> `la-latin1`.

### Verificando la conexión a internet

Arch Linux necesita conexión a internet para descargar paquetes durante
la instalación. Verifica que tu interfaz de red esté disponible:
```bash
ip link
```

Si usas Wi-Fi, configúralo con:
```bash
iwctl
```

Sigue las instrucciones en pantalla para conectarte a tu red.

Confirma que la conexión funciona:
```bash
ping 8.8.8.8
```

Si ves respuestas, la conexión está funcionando correctamente.

### Sincronizando el reloj del sistema

Configura la hora correcta usando servidores de tiempo de internet
para evitar problemas con certificados de seguridad:

```bash
timedatectl set-ntp true
```

### Identificando el modo de arranque

Los sistemas modernos pueden arrancar en modo UEFI o BIOS heredado.
Identifica cuál estás usando:

```bash
ls /sys/firmware/efi/efivars
```

Si el comando muestra archivos, estás en modo UEFI. Si muestra "No such file
or directory", estás en modo BIOS heredado. Este dato será importante
para los siguientes pasos.

## 1.3 El Arte del Particionado

El particionado requiere atención y cuidado para evitar pérdida de datos.

### Identificando tu disco

Lista todos los discos disponibles:

```bash
fdisk -l
```

Identifica tu disco principal: generalmente será `/dev/sda`
(discos SATA/IDE), `/dev/nvme0n1` (discos NVMe), o `/dev/mmcblk0`
(tarjetas SD/eMMC). **Verifica cuidadosamente cuál es tu disco
objetivo** antes de continuar.

### Creando las particiones

Usaremos el esquema de particiones GPT. La configuración depende del modo
de arranque:

**Para sistemas UEFI con GPT:**
- `/dev/sda1`: EFI System, 1024 MiB o más, montaje: `/mnt/boot`
- `/dev/sda2`: Linux swap, ver nota abajo, montaje: (swap)
- `/dev/sda3`: Linux filesystem, resto del disco, montaje: `/mnt`

**Para sistemas BIOS con GPT:**
- `/dev/sda1`: BIOS boot, 8 MiB, montaje: (no se monta)
- `/dev/sda2`: EFI boot, 1024 MiB o más, montaje: `/mnt/boot`
- `/dev/sda3`: Linux swap, ver nota abajo, montaje: (swap)
- `/dev/sda4`: Linux filesystem, resto del disco, montaje: `/mnt`

**Para sistemas BIOS con MBR:**
- `/dev/sda1`: Bootloader, 1024 MiB o más, montaje: `/mnt/boot`
- `/dev/sda2`: Linux swap, ver nota abajo, montaje: (swap)
- `/dev/sda3`: Linux, resto del disco, montaje: `/mnt`

**Recomendaciones para el tamaño de swap:**
- **Hasta 4 GB de RAM**: Swap = 1.5 × RAM (si quieres hibernación) o igual
  a RAM (sin hibernación)
- **4-16 GB de RAM**: 4 GB de swap suele ser suficiente
- **Más de 16 GB de RAM**: 4 GB + (0.1 × RAM total) es una buena regla general
- **Mínimo recomendado**: 2 GB en cualquier caso

> **Nota:** Los puntos de montaje `/mnt` y `/mnt/boot` son específicos del
> entorno de instalación. Una vez instalado el sistema, se montarán como `/` y `/boot`
> respectivamente.

Abre `cfdisk` para crear las particiones:

```bash
cfdisk /dev/sda
```

*Reemplaza `/dev/sda` con tu disco.*

Pasos en `cfdisk`:
1. Si el disco está vacío, selecciona el tipo de tabla:
   - **"gpt"** para sistemas UEFI o BIOS modernos (recomendado)
   - **"msdos"** solo si necesitas MBR para BIOS muy antiguos
2. Crea las particiones según el esquema de tu modo de arranque
3. Asigna los tipos correctos a cada partición
4. Escribe los cambios y sal

### Formateando las particiones

Formatea las particiones con los sistemas de archivos apropiados:

**Para sistemas UEFI con GPT:**
```bash
mkfs.fat -F 32 /dev/sda1  # Partición EFI (FAT32)
mkswap /dev/sda2          # Partición swap
mkfs.ext4 /dev/sda3       # Sistema de archivos principal (ext4)
```

**Para sistemas BIOS con GPT:**
```bash
# La partición BIOS boot (/dev/sda1) no se formatea
mkswap /dev/sda2          # Partición swap
mkfs.ext4 /dev/sda3       # Sistema de archivos principal (ext4)
```

**Para sistemas BIOS con MBR:**
```bash
mkswap /dev/sda1          # Partición swap
mkfs.ext4 /dev/sda2       # Sistema de archivos principal (ext4)
```

**Información adicional sobre sistemas de archivos:**

Si deseas explorar otras opciones de formateo, aquí están los comandos más
comunes con sus opciones recomendadas:

*Particiones EFI/ESP (paquete: dosfstools):*
```bash
mkfs.fat -F 32 /dev/sdaX               # Siempre FAT32 (-F 32) para particiones EFI
mkfs.fat -F 32 -n "EFI" /dev/sdaX
# Con etiqueta de volumen (-n)
```

*Partición swap (paquete: util-linux - incluido en base):*
```bash
mkswap /dev/sdaX                       # Sin opciones adicionales necesarias
mkswap -L "swap" /dev/sdaX
# Con etiqueta de volumen (-L)
```

*Sistema de archivos principal:*

- **ext4** (paquete: e2fsprogs - incluido en base) - recomendado para la mayoría,

estable y maduro:
```bash
mkfs.ext4 /dev/sdaX                              # Opciones por defecto (recomendado)
mkfs.ext4 -L "ArchLinux" /dev/sdaX               # Con etiqueta de volumen (-L)
mkfs.ext4 -L "ArchLinux" -O metadata_csum,64bit -E lazy_itable_init=0,lazy_journal_init=0
/dev/sdaX
# Opciones optimizadas para SSD
```

- **XFS** (paquete: xfsprogs) - bueno para archivos grandes y alto rendimiento,
no se puede reducir:
```bash
mkfs.xfs /dev/sdaX                               # Opciones por defecto
mkfs.xfs -L "ArchLinux" /dev/sdaX                # Con etiqueta de volumen (-L)
mkfs.xfs -L "ArchLinux" -m crc=1,finobt=1 /dev/sdaX
# Opciones modernas recomendadas
```

- **Btrfs** (paquete: btrfs-progs) - moderno, con snapshots y compresión,
requiere más conocimiento:
```bash
mkfs.btrfs /dev/sdaX                             # Opciones por defecto
mkfs.btrfs -L "ArchLinux" /dev/sdaX              # Con etiqueta de volumen (-L)
mkfs.btrfs -L "ArchLinux" -f /dev/sdaX
# Forzar formateo (-f) si la partición ya tiene datos
```

*Opciones explicadas:*
- `-L` o `-n`: Establece una etiqueta de volumen (útil para identificación y
  montaje por etiqueta)
- `-f`: Fuerza el formateo incluso si hay datos (usar con precaución)
- Para ext4 en SSD: `metadata_csum` mejora integridad, `lazy_*=0`
  inicializa todo inmediatamente
- Para XFS: `crc=1` habilita checksums de metadata, `finobt=1` mejora
  rendimiento con muchos archivos

> **Nota:** Para desktop/laptop, ext4 es la opción más segura y probada.
> XFS ofrece buen rendimiento para workstations con archivos grandes (no se puede reducir).
> Btrfs ofrece características avanzadas (snapshots, compresión, deduplicación)
> pero requiere más conocimiento para mantenimiento y recuperación.

**Consideración importante sobre backups con Timeshift:**
- **Btrfs**: Timeshift puede crear snapshots instantáneos del sistema usando las
  capacidades nativas de Btrfs. Esto es muy rápido y eficiente en espacio.
- **ext4/XFS/otros**: Timeshift utiliza rsync para hacer copias completas de
  archivos, lo cual consume más tiempo y espacio en disco.

### Montando las particiones

Monta las particiones para poder trabajar con ellas:

**Para sistemas UEFI con GPT:**
```bash
mount /dev/sda3 /mnt      # Montar el sistema de archivos principal
swapon /dev/sda2          # Activar la partición swap
mkdir /mnt/boot           # Crear el punto de montaje para EFI
mount /dev/sda1 /mnt/boot # Montar la partición EFI
```

**Para sistemas BIOS con GPT:**
```bash
mount /dev/sda3 /mnt      # Montar el sistema de archivos principal
swapon /dev/sda2          # Activar la partición swap
# La partición BIOS boot no se monta
```

**Para sistemas BIOS con MBR:**
```bash
mount /dev/sda2 /mnt      # Montar el sistema de archivos principal
swapon /dev/sda1          # Activar la partición swap
```

## 1.4 Optimizando los Mirrors (Opcional pero Recomendado)

Si la descarga de paquetes es lenta, puedes optimizar la lista de mirrors antes de
instalar:

```bash
pacman -S --needed reflector
reflector --country "Mexico,United States" --age 12 --protocol https \
--sort rate --save /etc/pacman.d/mirrorlist
```

*Reemplaza "Mexico,United States" con los países más cercanos a tu ubicación.
Puedes ver la lista completa de países con `reflector --list-countries`.*

**Automatización de reflector (opcional):** Si deseas que los mirrors se actualicen

automáticamente cada semana, puedes habilitar el timer de reflector después de

instalar el sistema base:
```bash
systemctl enable reflector.timer
```

Esto actualizará la lista de mirrors semanalmente.
Puedes personalizar las opciones de reflector editando
`/etc/xdg/reflector/reflector.conf` después de la instalación.

## 1.5 Instalando el Corazón del Sistema

Instala el sistema base de Arch Linux con los paquetes esenciales:

**Para sistemas BIOS:**
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub vim sudo nano
```

**Para sistemas UEFI (añade efibootmgr):**
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub \
efibootmgr vim sudo nano
```

**Para sistemas con dual boot (añade os-prober):**

Si tienes BIOS:
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub os-prober vim sudo nano
```

Si tienes UEFI:
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr \
os-prober vim sudo nano
```

Componentes instalados:
- **base**: El sistema base de Arch Linux
- **linux**: El kernel de Linux
- **linux-firmware**: Drivers de firmware para hardware común
- **networkmanager**: Gestión de red
- **grub**: El gestor de arranque
- **efibootmgr**: Herramienta para gestionar entradas de arranque UEFI (solo
  UEFI)
- **os-prober**: Detecta otros sistemas operativos para dual boot (opcional)
- **vim**: Editor de texto avanzado
- **sudo**: Permite ejecutar comandos con privilegios administrativos
- **nano**: Editor de texto simple

> **Nota:** El proceso puede tomar unos minutos dependiendo de tu conexión.

## 1.6 Configuración del Sistema Recién Instalado

### Generando el archivo fstab

El archivo `fstab` define qué particiones montar al arrancar:

```bash
genfstab -pU /mnt >> /mnt/etc/fstab
```

### Entrando al nuevo sistema

Accede al sistema recién instalado:

```bash
arch-chroot /mnt
```

A partir de aquí, los comandos se ejecutan dentro del nuevo sistema Arch Linux.

### Configurando la zona horaria

Configura tu ubicación geográfica. Reemplaza "Región" y "Ciudad" con tu
ubicación:

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Ejemplo para Ciudad de México:
```bash
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
```

Sincroniza el reloj del hardware:
```bash
hwclock --systohc
```

### Configuración de idioma y localización

Edita `/etc/locale.gen` (con `nano /etc/locale.gen` o
`vim /etc/locale.gen`) y descomenta los idiomas que necesites.
Incluye al menos `en_US.UTF-8` y tu idioma local (por ejemplo,
`es_ES.UTF-8` o `es_MX.UTF-8`).

Genera los idiomas:
```bash
locale-gen
```

Crea `/etc/locale.conf` con tu idioma principal:
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

> **Nota:** Puedes usar `LANG=es_ES.UTF-8` u otro idioma según prefieras.

Configura el teclado permanentemente en `/etc/vconsole.conf`:
```bash
echo "KEYMAP=la-latin1" > /etc/vconsole.conf
```

### Configuración de red

Asigna un nombre a tu computadora en `/etc/hostname`:
```bash
echo "mi-arch-mint" > /etc/hostname
```

Configura `/etc/hosts`:
```bash
cat >> /etc/hosts << EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      mi-arch-mint
EOF
```

> **Nota:** Usa el mismo nombre que pusiste en `/etc/hostname`.

### Configurando la contraseña de administrador

Establece una contraseña para el usuario root:
```bash
passwd
```

### Configuraciones opcionales de pacman

**Habilitando colores en pacman:**

Edita `/etc/pacman.conf` y descomenta la línea `Color`:
```bash
nano /etc/pacman.conf
```

Busca y descomenta (quita el `#`):
```ini
# Misc options
#UseSyslog
Color
#NoProgressBar
```

**Habilitando el repositorio multilib (para aplicaciones de 32 bits):**

Si planeas usar aplicaciones de 32 bits, Steam, Wine, o algunos juegos,
necesitas habilitar multilib.

En el mismo archivo `/etc/pacman.conf`, descomenta estas líneas al final del
archivo:
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Luego actualiza la base de datos de paquetes:
```bash
pacman -Syu
```

> **Nota:** Multilib es necesario para Steam, Wine,
> algunas aplicaciones propietarias de 32 bits, 
> y drivers gráficos de 32 bits para juegos.

## 1.7 El Gestor de Arranque GRUB

GRUB permite arrancar el sistema. La instalación varía según el modo de
arranque:

### Para sistemas BIOS heredado

```bash
grub-install --verbose --target=i386-pc /dev/sda
```

> **Nota:** Reemplaza `/dev/sda` con tu disco (sin número de partición).

### Para sistemas UEFI

```bash
grub-install --verbose --target=x86_64-efi --efi-directory=/boot
--bootloader-id=GRUB
```

### Habilitando las actualizaciones de microcódigo

Los procesadores modernos se benefician de las actualizaciones de
microcódigo para mejorar estabilidad y seguridad:

**Para procesadores Intel:**
```bash
pacman -S intel-ucode
```

- **intel-ucode**: Actualizaciones de microcódigo para procesadores Intel

**Para procesadores AMD:**
```bash
pacman -S amd-ucode
```

- **amd-ucode**: Actualizaciones de microcódigo para procesadores AMD

### Generando la configuración final de GRUB

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

**Si instalaste `os-prober` para dual boot**, habilítalo primero:
```bash
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
```

El comando debería detectar tu sistema Arch Linux y cualquier otro
sistema operativo instalado.

## 1.8 El Primer Arranque

Arranca el nuevo sistema:

```bash
exit                    # Salir del entorno chroot
umount -R /mnt         # Desmontar las particiones
sync                   # Sincronizar los discos
reboot now            # Reiniciar
```

Retira el medio de instalación antes de que arranque. Deberías ver el
menú de GRUB y luego una pantalla de login en modo texto.

Inicia sesión como "root" con tu contraseña.

### Ajustes post-instalación

Habilita NetworkManager para tener conectividad:

```bash
systemctl enable --now NetworkManager
```

Para configurar la red en modo texto, usa:
```bash
nmtui
```

Has completado la instalación base de Arch Linux. El siguiente capítulo
cubre la instalación del entorno de escritorio.

### Lista de Verificación - Capítulo 1

- [ ] Descargada la imagen ISO de Arch Linux
- [ ] Creado el medio de instalación (USB/DVD)
- [ ] Arranque desde el medio de instalación exitoso
- [ ] Teclado configurado correctamente
- [ ] Conexión a internet verificada
- [ ] Reloj del sistema sincronizado
- [ ] Modo de arranque identificado (UEFI/BIOS)
- [ ] Disco identificado y particiones creadas
- [ ] Particiones formateadas correctamente
- [ ] Particiones montadas en `/mnt`
- [ ] Mirrors optimizados (opcional)
- [ ] Sistema base instalado con pacstrap
- [ ] Archivo fstab generado
- [ ] Entrado al sistema con arch-chroot
- [ ] Zona horaria configurada
- [ ] Idioma y localización configurados
- [ ] Red configurada (hostname y hosts)
- [ ] Contraseña de root establecida
- [ ] Configuraciones opcionales de pacman aplicadas
- [ ] GRUB instalado y configurado
- [ ] Microcódigo instalado (si aplica)
- [ ] Sistema reiniciado y primer arranque exitoso
- [ ] NetworkManager habilitado

---

# Capítulo 2: La Transformación - Creando el Entorno de Escritorio

En este capítulo transformarás tu instalación base de Arch Linux en un sistema

que se ve y siente como Linux Mint.
Instalaremos el entorno de escritorio Cinnamon, configuraremos el AUR y

aplicaremos el tema visual característico de Mint.

## 2.1 Preparando el Escenario

### Creando un usuario para el escritorio

Es recomendable crear un usuario regular para las tareas diarias:

```bash
useradd -m -G wheel usuario
passwd usuario
```

> **Nota:** Reemplaza "usuario" con el nombre que prefieras.
> La opción `-G wheel` añade el usuario al grupo wheel,
> que es la práctica estándar en Arch para usuarios con privilegios de sudo.

## 2.2 Instalando los Componentes Visuales

Instala los componentes necesarios para el escritorio:

```bash
pacman -S xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter \
cinnamon cinnamon-translations gnome-terminal xdg-user-dirs xdg-user-dirs-gtk
```

Componentes instalados:
- **xorg**: El servidor gráfico X11
- **xorg-apps**: Aplicaciones básicas para X11
- **xorg-drivers**: Controladores de entrada para X11
- **mesa**: Controladores gráficos de código abierto
- **lightdm**: Gestor de inicio de sesión (display manager)
- **lightdm-slick-greeter**: Pantalla de login con el estilo de Linux Mint
- **cinnamon**: El entorno de escritorio de Linux Mint
- **cinnamon-translations**: Traducciones para Cinnamon (soporte de idiomas)
- **gnome-terminal**: Emulador de terminal
- **xdg-user-dirs**: Crea directorios estándar del usuario (Descargas, Documentos,
etc.)
- **xdg-user-dirs-gtk**: Integración GTK para gestión de directorios del
usuario

### Configurando LightDM

Edita `/etc/lightdm/lightdm.conf` (con `nano /etc/lightdm/lightdm.conf` o
`vim /etc/lightdm/lightdm.conf`) y en la sección `[Seat:*]`,
añade o descomenta:

```ini
[Seat:*]
greeter-session=lightdm-slick-greeter
```

### Probando el escritorio

Prueba LightDM antes de hacerlo permanente:

```bash
systemctl start lightdm
```

Si funciona correctamente, hazlo permanente:

```bash
systemctl enable lightdm
```

Reinicia e inicia sesión con tu usuario. Verás el escritorio Cinnamon.

### Lista de Verificación - Capítulo 2

- [ ] Usuario regular creado
- [ ] Componentes visuales instalados (Xorg, LightDM, Cinnamon)
- [ ] LightDM configurado con Slick Greeter
- [ ] Escritorio probado y funcionando
- [ ] Distribución de teclado configurada en Cinnamon
- [ ] Sudo configurado para el usuario
- [ ] Yay instalado y AUR habilitado
- [ ] Fuentes de Linux Mint instaladas y configuradas
- [ ] Temas e iconos de Mint instalados
- [ ] Fondos de pantalla de Mint instalados (opcional)
- [ ] Soporte para impresoras instalado (opcional)
- [ ] PipeWire instalado y funcionando
- [ ] Bluetooth instalado y configurado (opcional)

---

## 2.3 Configuraciones Esenciales

### Ajustando la distribución del teclado

Configura tu teclado en el entorno gráfico. Ve a:

**Menú de Cinnamon → Teclado → Distribuciones**

- Añade tu distribución con el botón (+)
- Elimina las que no uses con el botón (-)

> **Nota:** Al momento de escribir esta guía (noviembre 2025),
> las distribuciones de teclado solo funcionan en sesiones X11.
> El soporte para Wayland está en desarrollo y aún asi hoy 2025
> KDE y GNOME lo tienen por defecto.

### Configurando sudo para tu usuario

El paquete sudo ya está instalado, pero necesitas configurarlo para que tu usuario pueda ejecutar comandos
administrativos.

Cambia al usuario root:
```bash
su
```

Edita el archivo de configuración de sudoers:
```bash
EDITOR=vim visudo
```

**Instrucciones básicas de vim:**
1. Usa las flechas del teclado para moverte por el archivo
2. Busca la sección que dice `## User privilege specification`
3. Posiciónate al final de esa sección y presiona `o` para crear una nueva
línea
4. Escribe: `usuario ALL=(ALL) ALL` (reemplaza "usuario" con tu nombre de usuario)
5. Presiona `Esc` para salir del modo de edición
6. Escribe `:wq` y presiona `Enter` para guardar y salir

**Ejemplo de cómo debería quedar:**
```bash
## User privilege specification
##
root ALL=(ALL) ALL
usuario ALL=(ALL) ALL
```

*Si añadiste tu usuario al grupo wheel en el paso 2.1, alternativamente puedes
descomentar la línea `%wheel ALL=(ALL) ALL` en lugar de añadir tu usuario
individualmente.*

Si prefieres usar nano en lugar de vim:
```bash
EDITOR=nano visudo
```

Con nano es más simple: edita el archivo, presiona `Ctrl+O` para guardar, `Enter` para confirmar, y `Ctrl+X` para
salir.

Regresa a tu usuario:
```bash
su usuario
```

## 2.4 Habilitando el AUR - La Magia de Arch

El AUR (Arch User Repository) contiene miles de paquetes adicionales. Instala `yay` para acceder
fácilmente:

```bash
sudo pacman -S --needed git base-devel
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf ./yay/
yay -Syy
```

Paquetes instalados:
- **git**: Sistema de control de versiones (necesario para clonar repositorios del
AUR)
- **base-devel**: Grupo de paquetes con herramientas de compilación esenciales
- **yay**: Ayudante del AUR que simplifica la instalación de paquetes de la
comunidad

Con `yay`, tienes acceso a prácticamente cualquier software disponible para
Linux.

## 2.5 La Metamorfosis Visual - Haciendo que se Vea como Linux Mint

Instala los componentes visuales que dan a Linux Mint su apariencia
característica.

### Instalando las fuentes de Linux Mint

Instala las fuentes necesarias:

```bash
yay -S --needed noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra
yay -S --needed ttf-ubuntu-font-family
```

- **noto-fonts**: Familia de fuentes Noto (cobertura amplia de idiomas)
- **noto-fonts-emoji**: Fuentes Noto con soporte de emojis
- **noto-fonts-cjk**: Fuentes Noto para idiomas CJK (chino, japonés, coreano)
- **noto-fonts-extra**: Fuentes Noto adicionales
- **ttf-ubuntu-font-family**: Familia de fuentes Ubuntu (la predeterminada en Linux Mint)

Configúralas en **Menú de Cinnamon → Selección de Fuentes**:

- Fuente predeterminada:   Ubuntu Regular,    tamaño 10
- Fuente del escritorio:   Ubuntu Regular,    tamaño 10
- Fuente de documento:     Sans Regular,      tamaño 10
- Fuente monoespaciada:    Monospace Regular, tamaño 10
- Fuente de título:        Ubuntu Medium,     tamaño 10
### Instalando los temas e iconos oficiales

Instala los temas e iconos de Linux Mint:

```bash
yay -S --needed mint-theme mint-l-themes mint-y-icons mint-x-icons \
mint-l-icons bibata-cursor-theme xapp-symbolic-icons
```

- **mint-themes**: Temas de escritorio oficiales de Linux Mint
- **mint-l-theme**: Temas de escritorio Linux Mint Legacy
- **mint-y-icons**: Set de iconos Mint-Y (estilo moderno)
- **mint-x-icons**: Set de iconos Mint-X (estilo clásico)
- **mint-l-icons**: Set de iconos Mint-L
- **bibata-cursor-theme**: Tema de cursor Bibata
- **xapp-symbolic-icons**: Iconos simbólicos para aplicaciones XApp

Selecciona los temas en **Menú de Cinnamon → Temas**.

Para la pantalla de login:
```bash
yay -S --needed lightdm-settings
```

- **lightdm-settings**: Configurador gráfico para personalizar LightDM

### Fondos de pantalla de Linux Mint

Instala los fondos de pantalla oficiales:

**⚠️ Advertencia:** Estos paquetes descargan archivos grandes (70+ MiB cada
uno). Omite este paso si tienes conexión limitada.

```bash
yay -S --needed mint-backgrounds mint-artwork
```

- **mint-backgrounds**: Colección de fondos de pantalla oficiales de Linux Mint
- **mint-artwork**: Arte y recursos gráficos adicionales de Linux Mint

Selecciona los fondos en **Menú de Cinnamon → Fondos de Pantalla**.

## 2.6 Funcionalidad Adicional

### Soporte para impresoras

Para imprimir documentos:

```bash
yay -S --needed cups system-config-printer
sudo systemctl enable --now cups
```

- **cups**: Sistema de impresión CUPS (Common Unix Printing System)
- **system-config-printer**: Interfaz gráfica para configurar impresoras

### Audio (PipeWire)

Linux Mint y Arch Linux modernos utilizan PipeWire como servidor
de audio, que reemplaza a PulseAudio y JACK. PipeWire ofrece mejor
latencia y soporte para audio profesional.

Instala los componentes necesarios de PipeWire:

```bash
yay -S --needed pipewire-audio wireplumber pipewire-alsa pipewire-pulse \
pipewire-jack
```

Componentes instalados:
- **pipewire-audio**: Metapaquete que incluye PipeWire, WirePlumber y soporte para
ALSA/PulseAudio/JACK
- **wireplumber**: Gestor de sesión recomendado para PipeWire (reemplaza
pipewire-media-session)
- **pipewire-alsa**: Soporte ALSA para PipeWire
- **pipewire-pulse**: Implementación compatible con PulseAudio (reemplaza PulseAudio)
- **pipewire-jack**: Soporte JACK para aplicaciones de audio profesional

Los servicios de usuario de PipeWire se inician automáticamente al
iniciar sesión. Para verificar que funciona:

```bash
pactl info
```

Deberías ver `Server Name: PulseAudio (on PipeWire x.y.z)` en la salida.

> **Nota:** Cinnamon tiene su propio control de volumen integrado.
> Si necesitas controles más avanzados (por ejemplo,
> para cambiar perfiles de dispositivos o configurar aplicaciones individuales),
> puedes instalar opcionalmente:

```bash
yay -S --needed pavucontrol
```

- **pavucontrol**: Control de volumen avanzado (opcional, funciona con PipeWire vía compatibilidad PulseAudio)

### Bluetooth

Para soporte completo de Bluetooth (teclados, ratones, auriculares, etc.):

```bash
yay -S --needed bluez bluez-utils
sudo systemctl enable --now bluetooth
```

Componentes instalados:
- **bluez**: Stack de protocolo Bluetooth para Linux
- **bluez-utils**: Herramientas de línea de comandos (bluetoothctl, etc.)

Para emparejar dispositivos desde la terminal, usa `bluetoothctl`:

```bash
bluetoothctl
```

Comandos básicos en bluetoothctl:
- `power on` - Enciende el adaptador Bluetooth
- `scan on` - Busca dispositivos cercanos
- `pair XX:XX:XX:XX:XX:XX` - Empareja con un dispositivo (reemplaza XX... con la dirección
MAC)
- `trust XX:XX:XX:XX:XX:XX` - Confía en el dispositivo para reconexión
  automática
- `connect XX:XX:XX:XX:XX:XX` - Conecta al dispositivo
- `exit` - Sale de bluetoothctl

> **Nota:** Más adelante en la guía instalaremos Blueberry,
> el gestor gráfico de Bluetooth de Linux Mint,
> que facilita el emparejamiento desde la interfaz gráfica.

**Para auriculares/altavoces Bluetooth:**

El soporte de audio Bluetooth ya está incluido con `pipewire-audio`.
Los dispositivos de audio Bluetooth deberían aparecer automáticamente como
salidas de audio disponibles una vez emparejados y conectados.

# Capítulo 3: Completando la Experiencia - Las Aplicaciones de Linux Mint

En este capítulo instalaremos las aplicaciones predeterminadas de Linux
Mint para completar la experiencia de usuario. Desde herramientas de
productividad hasta multimedia y optimizaciones para laptops, lograrás
un sistema funcional y completo.

## 3.1 Aplicaciones de Productividad y Utilidades

### Herramientas del sistema y accesorios

Aplicaciones básicas de Linux Mint:

```bash
yay -S --needed file-roller yelp warpinator mintstick xed gnome-screenshot \
redshift seahorse onboard sticky xviewer gnome-font-viewer bulky xreader \
gnome-disk-utility gucharmap gnome-calculator
```

Funciones de cada aplicación:
- **file-roller**: Gestor de archivos comprimidos
- **yelp**: Visor de ayuda del sistema
- **warpinator**: Transferencia de archivos entre dispositivos de red
- **mintstick**: Creador de USBs de arranque
- **xed**: Editor de texto avanzado
- **gnome-screenshot**: Captura de pantalla
- **redshift**: Filtro de luz azul
- **seahorse**: Gestor de claves y contraseñas
- **onboard**: Teclado virtual en pantalla
- **sticky**: Notas adhesivas
- **xviewer**: Visor de imágenes
- **gnome-font-viewer**: Visor de fuentes
- **bulky**: Renombrador masivo de archivos
- **xreader**: Visor de documentos PDF
- **gnome-disk-utility**: Utilidad de discos
- **gucharmap**: Mapa de caracteres
- **gnome-calculator**: Calculadora

### Aplicaciones gráficas

Para trabajo con imágenes y digitalización:

```bash
yay -S --needed simple-scan pix drawing
```

- **simple-scan**: Aplicación de escaneo
- **pix**: Organizador y editor básico de fotos
- **drawing**: Aplicación de dibujo

## 3.2 Aplicaciones de Internet y Comunicación

```bash
yay -S --needed firefox webapp-manager thunderbird transmission-gtk
```

- **firefox**: Navegador web
- **webapp-manager**: Convierte sitios web en aplicaciones de escritorio
- **thunderbird**: Cliente de correo electrónico
- **transmission-gtk**: Cliente de BitTorrent

> **Nota sobre HexChat:** Esta aplicación está actualmente disponible en el AUR
> pero requiere GTK2, que también está en el AUR.
> Instalar HexChat implicará compilar tanto GTK2 como HexChat con `yay`.
> Además, HexChat ya no recibe mantenimiento activo.
> Y aunque formaba parte de Linux Mint, su instalación queda a criterio
> del usuario en esta guía y según si vale la pena el esfuerzo de compilación.

> **Nota sobre Elements:** Con el fin del desarrollo de HexChat y el surgimiento
> de alternativas, Linux Mint ahora incluye un cliente Matrix, más específicamente
> `Elements`, que en la instalación original es una aplicación web utilizando
> `Webapp-manager`, sin embargo, un cliente nativo también existe.
> Arch Linux contiene ambos en sus repositorios oficiales bajo los nombres de
> `element-desktop` y `element-web`, así que queda a su discreción
> si desea instalar uno o el otro, o ninguno.

## 3.3 Suite de Oficina

Productividad y gestión del tiempo:

```bash
yay -S --needed gnome-calendar libreoffice-fresh
```

- **gnome-calendar**: Calendario integrado
- **libreoffice-fresh**: Suite de oficina completa

## 3.4 Herramientas de Desarrollo

Para programación:

```bash
yay -S --needed python
```

- **python**: Intérprete Python (fundamental para muchas aplicaciones)

## 3.5 Multimedia

Aplicaciones para audio y vídeo:

```bash
yay -S --needed celluloid hypnotix rhythmbox
```

- **celluloid**: Reproductor de vídeo basado en MPV
- **hypnotix**: Cliente para IPTV y streaming
- **rhythmbox**: Reproductor de música y gestor de biblioteca

## 3.6 Herramientas de Administración

Gestión y monitoreo del sistema:

```bash
yay -S --needed baobab gnome-logs timeshift fingwit
```

- **baobab**: Analizador de uso de disco (visualiza el espacio usado)
- **gnome-logs**: Visor de logs del sistema (para leer logs)
- **timeshift**: Respaldos del sistema (permite crear y restaurar instantáneas)

## 3.7 Configuración y Preferencias

Personalización del sistema:

```bash
yay -S --needed gufw blueberry mintlocale gnome-online-accounts-gtk
```

- **gufw**: Interfaz para el firewall (gestión visual de reglas de red)
- **blueberry**: Gestor de Bluetooth (conexión de auriculares, teclados, etc.)
- **mintlocale**: Configuración de idiomas del sistema (interfaz de Linux Mint)
- **gnome-online-accounts-gtk**: Integración de cuentas online (Google, MSFT, etc.)

Habilita el firewall:
```bash
sudo systemctl enable --now ufw
```

- **ufw** (Uncomplicated Firewall): Firewall que protege tu sistema de conexiones no
autorizadas

## 3.8 Herramientas del Sistema y Línea de Comandos

### Compatibilidad con sistemas de archivos

Para compatibilidad con diferentes tipos de almacenamiento:

```bash
yay -S --needed ntfs-3g dosfstools mtools exfatprogs
```

- **ntfs-3g**: Soporte de lectura/escritura para particiones NTFS (Windows)
- **dosfstools**: Utilidades para sistemas de archivos FAT
- **mtools**: Herramientas para acceder a discos MS-DOS
- **exfatprogs**: Soporte para sistemas de archivos exFAT

*Opcional para sistemas de archivos avanzados:*
```bash
yay -S --needed btrfs-progs xfsprogs e2fsprogs
```

- **btrfs-progs**: Utilidades para el sistema de archivos Btrfs
- **xfsprogs**: Utilidades para el sistema de archivos XFS
- **e2fsprogs**: Utilidades para sistemas de archivos ext2/ext3/ext4

### Herramientas de compresión

Para trabajar con cualquier formato de archivo comprimido:

```bash
yay -S --needed unrar unace unarj arj lha lzo lzop unzip zip cpio pax p7zip
```

- **unrar**: Descompresor de archivos RAR
- **unace**: Descompresor de archivos ACE
- **unarj**: Descompresor de archivos ARJ
- **arj**: Compresor/descompresor ARJ
- **lha**: Compresor/descompresor LHA
- **lzo** y **lzop**: Compresor rápido LZO
- **unzip** y **zip**: Compresor/descompresor ZIP
- **cpio**: Utilidad de archivo cpio
- **pax**: Utilidad de archivo POSIX
- **p7zip**: Compresor/descompresor 7-Zip

> **Nota:** `rar` del AUR puede conflictar con `unrar`. Elige según necesidades.

### Integraciones adicionales

Para integración completa con el gestor de archivos Nemo:

```bash
yay -S --needed xviewer-plugins nemo-fileroller gvfs-goa gvfs-onedrive gvfs-google
```

- **xviewer-plugins**: Plugins adicionales para el visor de imágenes
- **nemo-fileroller**: Integración de compresión/descompresión en Nemo
- **gvfs-goa**: Soporte para GNOME Online Accounts en el gestor de archivos
- **gvfs-onedrive**: Acceso a OneDrive desde el gestor de archivos
- **gvfs-google**: Acceso a Google Drive desde el gestor de archivos

## 3.9 Optimizaciones para Laptops (Opcional)

Si estás instalando en una laptop, estas herramientas pueden mejorar
significativamente la gestión de energía y la experiencia general:

### Gestión de energía y batería

Tienes dos opciones principales (elige solo una):

**Opción 1: TLP (recomendado para máximo ahorro de energía)**

```bash
yay -S --needed tlp tlp-rdw
sudo systemctl enable --now tlp
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

- **tlp**: Gestión avanzada de energía para laptops (optimiza automáticamente la
batería)
- **tlp-rdw**: Extensión para gestión de radio devices (WiFi, Bluetooth) con
TLP

*Los comandos `mask` son necesarios porque TLP maneja rfkill directamente.*

**Dependencias opcionales útiles para TLP:**

```bash
yay -S --needed ethtool smartmontools
```

- **ethtool**: Permite desactivar Wake-on-LAN para ahorrar energía
- **smartmontools**: Muestra datos S.M.A.R.T. del disco en `tlp-stat`

**Opción 2: Power Profiles Daemon (más simple, integración con escritorio)**

```bash
yay -S --needed power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

- **power-profiles-daemon**: Gestión de perfiles de energía (Rendimiento, Balanceado,
Ahorro de energía)

*Más simple que TLP pero menos configurable. Se integra mejor con
applets de escritorio.*

**⚠️ Importante**: No instales ambos a la vez, ya que conflictúan.
Elige TLP para máximo control o power-profiles-daemon para simplicidad.

### Herramientas del kernel para laptops

```bash
yay -S --needed linux-tools-meta
```

- **linux-tools-meta**: Metapaquete que incluye herramientas útiles del kernel
como `cpupower`, `turbostat`, etc.

### Información del sistema y sensores

```bash
yay -S --needed lm_sensors
sudo sensors-detect
```

- **lm_sensors**: Detecta y muestra información de sensores de hardware
(temperatura, ventiladores, voltaje)

Ejecuta `sensors-detect` y acepta las opciones predeterminadas. Luego
puedes usar `sensors` para ver las temperaturas.

### Control de brillo de pantalla

El control de brillo debería funcionar automáticamente con Cinnamon, pero si tienes problemas:

```bash
yay -S --needed brightnessctl
```

- **brightnessctl**: Utilidad para controlar el brillo de la pantalla desde línea de
comandos

### Soporte para touchpad avanzado

```bash
yay -S --needed xf86-input-synaptics xf86-input-libinput
```

- **xf86-input-synaptics**: Driver mejorado para touchpads Synaptics 
> (Driver en modo mantenimiento)
- **xf86-input-libinput**: Driver moderno y predeterminado para touchpads
> y otros dispositivos de entrada similares (libinput, etc.)

> **Nota:** La mayoría de touchpads modernos funcionan bien con el driver
> libinput predeterminado. Solo instala synaptics si necesitas características
> no disponibles en el libinput o por compatibilidad.

### Lista de Verificación - Capítulo 3

- [ ] Aplicaciones de productividad instaladas
- [ ] Aplicaciones gráficas instaladas
- [ ] Aplicaciones de internet instaladas
- [ ] Suite de oficina instalada
- [ ] Herramientas de desarrollo instaladas
- [ ] Aplicaciones multimedia instaladas
- [ ] Herramientas de administración instaladas
- [ ] Configuración y preferencias instaladas
- [ ] Herramientas del sistema instaladas
- [ ] Optimizaciones para laptops aplicadas (si aplica)

---

## Conclusión

Has completado la creación de tu Linux Mint Arch Edition. El sistema:

- Se ve y funciona como Linux Mint
- Mantiene la base y flexibilidad de Arch Linux
- Tiene acceso al AUR para software adicional

### Próximos pasos recomendados

1. Configura Timeshift para respaldos automáticos
2. Personaliza el escritorio a tu gusto
3. Explora el AUR para software adicional
4. Si instalaste TLP, revisa su configuración en `/etc/tlp.conf` para
   ajustes personalizados

## Mantenimiento del Sistema

### Actualizando el sistema

Arch Linux es una distribución rolling-release,
lo que significa que recibes actualizaciones continuas.
Es importante mantener el sistema actualizado regularmente.

**Actualizar paquetes oficiales:**
```bash
sudo pacman -Syu
```

**Actualizar paquetes del AUR y oficiales:**
```bash
yay -Syu
```

**Recomendaciones:**
- Actualiza al menos una vez por semana
- Lee las noticias en [https://archlinux.org/](https://archlinux.org/) antes de
  actualizar para estar al tanto de cambios importantes
- Si usas software del AUR, `yay -Syu` actualizará tanto los repositorios
  oficiales como el AUR
- Después de actualizaciones importantes del kernel, considera reiniciar el
  sistema

**Limpiar caché de paquetes (opcional):**
```bash
sudo pacman -Sc
```

Esto elimina paquetes antiguos del caché para liberar espacio en disco.

## Glosario

- **AUR (Arch User Repository)**: Repositorio de paquetes mantenido por la
  comunidad de Arch Linux, que permite instalar software no disponible en los
  repositorios oficiales.
- **BIOS**: Sistema básico de entrada/salida, el firmware tradicional para arrancar.
- **Cinnamon**: Entorno de escritorio moderno y elegante desarrollado por Linux Mint.
- **EFI (Extensible Firmware Interface)**: Interfaz de firmware extensible.
- **fstab**: Archivo que define cómo se montan las particiones del sistema.
- **GRUB**: Gestor de arranque que permite seleccionar el sistema operativo al iniciar.
- **pacman**: Gestor de paquetes de Arch Linux.
- **PipeWire**: Servidor de audio y vídeo moderno que reemplaza a
  PulseAudio y JACK.
- **UEFI**: Interfaz de firmware unificada extensible, el estándar moderno
  para el firmware de computadoras.
- **yay**: Ayudante del AUR que facilita la instalación de paquetes desde el AUR.

## Enlaces Útiles

- [Sitio oficial de Arch Linux](https://archlinux.org/)
- [Wiki de Arch Linux](https://wiki.archlinux.org/)
- [Sitio oficial de Linux Mint](https://linuxmint.com/)
- [Documentación de Cinnamon](https://linuxmint-user-guide.readthedocs.io/en/latest/)
- [Foro de Arch Linux](https://bbs.archlinux.org/)
- [AUR (Arch User Repository)](https://aur.archlinux.org/)
