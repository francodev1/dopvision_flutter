#!/usr/bin/env python3
"""
Script para criar o logo do DoPVision em PNG de alta qualidade
Requer: Pillow (pip install Pillow)
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_logo(size=1024):
    """Cria um logo profissional do DoPVision"""
    
    # Criar imagem com fundo transparente
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Cores (baseado no AppTheme)
    primary = (99, 102, 241)      # #6366F1 - Indigo
    secondary = (139, 92, 246)    # #8B5CF6 - Purple
    
    # Criar gradiente circular
    center = size // 2
    radius = int(size * 0.42)
    
    # Desenhar fundo com gradiente (aproximado com círculos concêntricos)
    for i in range(radius, 0, -1):
        # Interpolar cores do gradiente
        t = i / radius
        r = int(primary[0] * t + secondary[0] * (1 - t))
        g = int(primary[1] * t + secondary[1] * (1 - t))
        b = int(primary[2] * t + secondary[2] * (1 - t))
        
        alpha = 255
        draw.ellipse(
            [center - i, center - i, center + i, center + i],
            fill=(r, g, b, alpha)
        )
    
    # Adicionar borda com arredondamento
    border_radius = int(size * 0.25)
    
    # Criar máscara para bordas arredondadas
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [0, 0, size, size],
        radius=border_radius,
        fill=255
    )
    
    # Aplicar máscara
    img.putalpha(mask)
    
    # Desenhar ícone (gráfico de barras crescente - representando performance)
    icon_size = int(size * 0.5)
    icon_start = (size - icon_size) // 2
    
    bar_width = icon_size // 5
    bar_spacing = icon_size // 6
    
    # 3 barras crescentes
    for i in range(3):
        bar_height = int(icon_size * (0.3 + i * 0.25))
        x = icon_start + i * (bar_width + bar_spacing)
        y = center + icon_size // 4 - bar_height
        
        draw.rounded_rectangle(
            [x, y, x + bar_width, center + icon_size // 4],
            radius=bar_width // 4,
            fill=(255, 255, 255, 255)
        )
    
    # Adicionar linha de tendência (seta crescente)
    arrow_points = [
        (icon_start, center + icon_size // 6),
        (icon_start + icon_size * 0.4, center - icon_size // 8),
        (icon_start + icon_size * 0.8, center - icon_size // 4),
    ]
    
    # Desenhar linha de tendência
    for i in range(len(arrow_points) - 1):
        draw.line(
            [arrow_points[i], arrow_points[i + 1]],
            fill=(255, 255, 255, 200),
            width=size // 80
        )
    
    # Adicionar ponta da seta
    last_point = arrow_points[-1]
    arrow_size = size // 30
    arrow_tip = [
        last_point,
        (last_point[0] - arrow_size, last_point[1] + arrow_size),
        (last_point[0] - arrow_size // 2, last_point[1]),
        (last_point[0] - arrow_size, last_point[1] - arrow_size),
    ]
    draw.polygon(arrow_tip, fill=(255, 255, 255, 200))
    
    return img

def main():
    """Gera logos em vários tamanhos"""
    
    print("🎨 Gerando logo DoPVision...")
    
    # Tamanhos necessários
    sizes = {
        'logo.png': 1024,              # Logo principal
        'logo_foreground.png': 1024,   # Para adaptive icon (Android)
    }
    
    for filename, size in sizes.items():
        print(f"  Criando {filename} ({size}x{size})...")
        logo = create_logo(size)
        logo.save(filename, 'PNG')
    
    print("✅ Logos gerados com sucesso!")
    print("\nPróximos passos:")
    print("1. Execute: flutter pub run flutter_launcher_icons")
    print("2. Isso irá gerar todos os ícones para iOS e Android")

if __name__ == '__main__':
    main()
