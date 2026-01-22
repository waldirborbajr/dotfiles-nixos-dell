{ lib, ... }:

{
  ############################################
  # Ajustes de performance no Dell (i3)
  ############################################

  # Limitar animações no i3 (caso precise)
  services.xserver.windowManager.i3.extraConfig = ''
    # Desabilitar animações do i3
    exec --no-startup-id feh --bg-scale /path/to/background.png  # Alterar o plano de fundo
  '';

  # Configurações de otimização para baixo consumo de memória
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkDefault 10;  # Menor uso de swap
    "vm.dirty_ratio" = 10;                # Menor taxa de gravação em disco
  };

  # Ativar zram para reduzir uso de swap
  boot.zram.enable = true;
}
