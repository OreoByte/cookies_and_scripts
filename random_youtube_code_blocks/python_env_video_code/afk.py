#!/usr/bin/python
import pygame
import noise
import random
import math

# Initialize pygame
pygame.init()

# Window settings
WIDTH, HEIGHT = 900, 900
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("AFK Animation Window")

clock = pygame.time.Clock()
running = True

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

# Perlin noise settings
scale = 100.0
octaves = 6
persistence = 0.5
lacunarity = 2.0
seed = random.randint(0, 100)

# Some moving circles/particles
particles = [{
    "x": random.uniform(0, WIDTH),
    "y": random.uniform(0, HEIGHT),
    "radius": random.uniform(5, 15),
    "color": [random.randint(100, 255) for _ in range(3)],
    "speed": random.uniform(0.5, 1.5),
    "angle": random.uniform(0, 2 * math.pi)
} for _ in range(50)]

def update_particles():
    for p in particles:
        # Simple movement based on angle
        p['x'] += math.cos(p['angle']) * p['speed']
        p['y'] += math.sin(p['angle']) * p['speed']

        # Bounce off walls
        if p['x'] <= 0 or p['x'] >= WIDTH:
            p['angle'] = math.pi - p['angle']
        if p['y'] <= 0 or p['y'] >= HEIGHT:
            p['angle'] = -p['angle']

def draw_particles():
    for p in particles:
        pygame.draw.circle(screen, p['color'], (int(p['x']), int(p['y'])), int(p['radius']))

frame = 0
while running:
    clock.tick(60)
    screen.fill(BLACK)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Draw a noise-generated wavy background
    for y in range(0, HEIGHT, 10):
        for x in range(0, WIDTH, 10):
            value = noise.pnoise3(x / scale,
                                  y / scale,
                                  frame / 60,
                                  octaves=octaves,
                                  persistence=persistence,
                                  lacunarity=lacunarity,
                                  repeatx=1024,
                                  repeaty=1024,
                                  base=seed)
            brightness = max(0, min(255, int((value + 0.5) * 255)))
            pygame.draw.rect(screen, (brightness, brightness, brightness), (x, y, 10, 10))

    # Update and draw particles
    update_particles()
    draw_particles()

    pygame.display.flip()
    frame += 1

pygame.quit()
