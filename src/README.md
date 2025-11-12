# LMAE Installation Scripts

Scripts de instalación automatizada para Linux Mint Arch Edition.

## Descripción

Estos scripts automatizan el proceso de instalación descrito en el README principal, dividiendo el proceso en pasos manejables y seguros.

## Requisitos Previos

- Medio de instalación de Arch Linux arrancado
- Particiones ya creadas y formateadas
- Conexión a internet configurada

## Orden de Ejecución

### 1. `01-base-install.sh` (Desde el medio de instalación)

Instala el sistema base de Arch Linux.

**Cuándo ejecutar:** Después de particionar y formatear los discos.

```bash
bash 01-base-install.sh
```

**Qué hace:**
- Detecta el modo de arranque (UEFI/BIOS)
- Optimiza mirrors con reflector
- Instala el sistema base con pacstrap
- Genera fstab

### 2. `02-configure-system.sh` (Dentro de arch-chroot)

Configura el sistema recién instalado.

**Cuándo ejecutar:** Después de hacer `arch-chroot /mnt`

```bash
# Primero copiar el script al chroot
cp 02-configure-system.sh /mnt/root/

# Entrar al chroot
arch-chroot /mnt

# Ejecutar el script
bash /root/02-configure-system.sh
```

**Qué hace:**
- Configura zona horaria, locale y teclado
- Configura hostname y red
- Establece contraseña de root
- Habilita multilib y Color en pacman
- Instala microcódigo (Intel/AMD)
- Instala y configura GRUB
- Habilita NetworkManager y reflector.timer

### 3. `03-desktop-install.sh` (Después del primer reinicio, como root)

Instala el entorno de escritorio Cinnamon.

**Cuándo ejecutar:** Después del primer reinicio, como root

```bash
bash 03-desktop-install.sh
```

**Qué hace:**
- Crea usuario de escritorio
- Configura sudo
- Instala Xorg y Cinnamon
- Configura LightDM
- Instala git y base-devel para AUR

### 4. `04-install-yay.sh` (Como usuario regular)

Instala yay, el helper del AUR.

**Cuándo ejecutar:** Después de reiniciar e iniciar sesión como usuario regular

```bash
bash 04-install-yay.sh
```

**Qué hace:**
- Clona y compila yay desde AUR
- Actualiza la base de datos de paquetes

### 5. `05-install-packages.sh` (Como usuario regular)

Instala todas las aplicaciones y paquetes de Linux Mint.

**Cuándo ejecutar:** Después de instalar yay

```bash
bash 05-install-packages.sh
```

**Qué hace:**
- Instala fuentes
- Instala temas e iconos de Linux Mint
- Instala soporte para impresoras
- Instala PipeWire (audio)
- Instala Bluetooth
- Instala todas las aplicaciones de Linux Mint
- Opcionalmente instala optimizaciones para laptops

## Proceso Completo

```bash
# 1. Desde el medio de instalación (después de particionar)
bash 01-base-install.sh

# 2. Copiar script y entrar al chroot
cp 02-configure-system.sh /mnt/root/
arch-chroot /mnt
bash /root/02-configure-system.sh
exit

# 3. Desmontar y reiniciar
umount -R /mnt
sync
reboot now

# 4. Después del reinicio, como root
bash 03-desktop-install.sh
reboot now

# 5. Después del reinicio, como usuario regular
bash 04-install-yay.sh
bash 05-install-packages.sh

# 6. Reiniciar una vez más
reboot
```

## Personalización

Antes de ejecutar los scripts, puedes editarlos para:

- Cambiar el país de reflector (por defecto: United States)
- Modificar la lista de paquetes a instalar
- Ajustar configuraciones específicas

## Notas Importantes

- **Siempre revisa los scripts antes de ejecutarlos**
- Los scripts usan `set -e` para detenerse ante errores
- Algunos scripts requieren entrada del usuario (hostname, contraseña, etc.)
- El script de paquetes pregunta antes de instalar wallpapers (70+ MiB)
- El script de paquetes pregunta antes de instalar optimizaciones de laptop

## Solución de Problemas

Si un script falla:

1. Lee el mensaje de error
2. Corrige el problema manualmente
3. Continúa con el siguiente paso o vuelve a ejecutar el script

Los scripts están diseñados para ser idempotentes cuando sea posible (usar `--needed` en instalaciones de paquetes).

## Contribuciones

Si encuentras errores o mejoras, por favor abre un issue o pull request en el repositorio.
