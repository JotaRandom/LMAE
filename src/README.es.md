# Scripts de Instalación LMAE

Scripts de instalación automatizada para Linux Mint Arch Edition.

## ⚠️ ADVERTENCIA - ESTADO EXPERIMENTAL

**Estos scripts son experimentales y se proporcionan tal cual (AS-IS) sin garantías.**

- **NO** son un reemplazo del instalador oficial de Arch Linux
- **NO** han sido probados exhaustivamente en todos los escenarios posibles
- **Pueden contener errores** que resulten en un sistema no booteable o pérdida de datos
- **Se recomienda encarecidamente** seguir la guía manual del README principal para entender cada paso
- Úsalos bajo tu propio riesgo, especialmente en sistemas de producción o datos importantes
- **Haz copias de seguridad** antes de usar estos scripts

**Para usuarios nuevos:** Se recomienda seguir la guía manual paso a paso para comprender el proceso de instalación.

**Para usuarios experimentados:** Estos scripts pueden ahorrar tiempo en reinstalaciones, pero revisa el código antes de ejecutarlo.

## Uso Rápido (Recomendado)

El script maestro detecta automáticamente el entorno y ejecuta el script apropiado:

```bash
bash 00-install-lmae.sh
```

Detecta si estás en:

- **Live CD**: Instalación base
- **Chroot**: Configuración del sistema
- **Sistema instalado sin escritorio**: Instalación de escritorio
- **Sistema con escritorio**: Instalación de YAY y paquetes

## Scripts Disponibles

| # | Script | Ejecutar como | Cuándo |
|---|--------|---------------|--------|
| 0 | `00-install-lmae.sh` | root/usuario | En cualquier momento (detecta automáticamente) |
| 1 | `01-base-install.sh` | root | Desde medio de instalación, después de particionar |
| 2 | `02-configure-system.sh` | root | Dentro de arch-chroot |
| 3 | `03-desktop-install.sh` | root | Después del primer reinicio |
| 4 | `04-install-yay.sh` | usuario | Después de reiniciar con escritorio |
| 5 | `05-install-packages.sh` | usuario | Después de instalar yay |

## Proceso Completo

### Con Script Maestro (Recomendado)

```bash
# En cada etapa, simplemente ejecuta:
bash 00-install-lmae.sh
```

### Manual (Scripts Individuales)

```bash
# 1. Desde medio de instalación
bash 01-base-install.sh

# 2. En chroot
cp 02-configure-system.sh /mnt/root/
arch-chroot /mnt
bash /root/02-configure-system.sh
exit

# 3. Desmontar y reiniciar
umount -R /mnt
sync
reboot

# 4. Después del reinicio (como root)
bash 03-desktop-install.sh
reboot

# 5. Después del reinicio (como usuario)
bash 04-install-yay.sh
bash 05-install-packages.sh
reboot
```

## Personalización

Edita los scripts antes de ejecutarlos para:

- Cambiar el país de reflector
- Modificar la lista de paquetes
- Ajustar configuraciones específicas

## Notas Importantes

- **Siempre revisa los scripts antes de ejecutarlos**
- Los scripts se detienen ante errores (`set -e`)
- Algunos requieren entrada del usuario
- Diseñados para ser idempotentes cuando es posible

## Solución de Problemas

Si un script falla:

1. Lee el mensaje de error
2. Corrige el problema manualmente
3. Continúa con el siguiente paso o vuelve a ejecutar

## Contribuciones

Si encuentras errores o mejoras, abre un issue o pull request en el repositorio.
