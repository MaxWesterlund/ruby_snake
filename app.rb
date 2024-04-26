require 'ruby2d'

WIN_RES_X = 1280
WIN_RES_Y = 720

GAME_RES_X = 32
GAME_RES_Y = 18 

BACKGROUND_COLOR = [0.9, 0.9, 0.9, 1]
LINE_COLOR = [0, 0, 0, 0.08]
OUTLINE_COLOR = [0, 0, 0, 1]

X_RES = WIN_RES_X / GAME_RES_X
Y_RES = WIN_RES_Y / GAME_RES_Y

DELAY = 7

OUTLINE_WIDTH = 4

class Vec2
    attr_reader :x , :y

    def initialize(x, y)
        @x = x
        @y = y
    end
end

class GameSquare
    attr_reader :pos

    def initialize(pos, col)
        @pos = pos

        @rect = Rectangle.new(
            x: pos.x * X_RES, y: pos.y * Y_RES,
            width: X_RES, height: Y_RES,
            color: col
        )
        @outline = Rectangle.new(
            x: pos.x * X_RES - OUTLINE_WIDTH, y: pos.y * Y_RES - OUTLINE_WIDTH,
            width: X_RES + 2 * OUTLINE_WIDTH, height: Y_RES + 2 * OUTLINE_WIDTH,
            color: OUTLINE_COLOR,
            z: -1
        )
    end

    def set_position(pos)
        @pos = pos
        @rect.x = pos.x * X_RES
        @rect.y = pos.y * Y_RES
        @outline.x = pos.x * X_RES - OUTLINE_WIDTH
        @outline.y = pos.y * Y_RES - OUTLINE_WIDTH
    end

    def set_color(col)
        @rect.color = col
    end
end

def find_new_food_pos(snake)
    new_pos = Vec2.new(rand(GAME_RES_X), rand(GAME_RES_Y))
    found = false
    while !found
        found = true
        snake.each do |part|
            if new_pos.x == part.pos.x && new_pos.y == part.pos.y
                new_pos = Vec2.new(rand(GAME_RES_X), rand(GAME_RES_Y))
                found = false
                break
            end
        end
    end

    return new_pos
end

def get_rand_col()
    return [rand(0.1..0.85), rand(0.1..0.85), rand(0.1..0.85), 1]
end

set title: "Mask"
set width: WIN_RES_X, height: WIN_RES_Y
set background: BACKGROUND_COLOR

# for x in 0..GAME_RES_X - 1
#     if x % 2 == 0
#         Rectangle.new(
#             x: x * X_RES, y: 0,
#             width: X_RES, height: WIN_RES_Y,
#             color: LINE_COLOR
#         )
#     end
# end

# for y in 0..GAME_RES_Y - 1
#     if y % 2 == 0
#         Rectangle.new(
#             x: 0, y: y * Y_RES,
#             width: WIN_RES_X, height: Y_RES,
#             color: LINE_COLOR
#         )
#     end
# end

snake_color_1 = get_rand_col()
snake_color_2 = get_rand_col()

snake = [GameSquare.new(Vec2.new(GAME_RES_X / 2, GAME_RES_Y / 2), snake_color_1)]
dir = "right"
inputs = [nil, nil, nil]


food = GameSquare.new(find_new_food_pos(snake), snake_color_2)

last_move_time = 0
paused = false
tick = 0

on :key_down do |event|
    key = event.key

    if key == "p"
        paused = !paused
    end

    if paused
        next
    end

    if ["up", "down", "left", "right"].include?(key)
        inputs << key
        inputs.shift(1)
        if !(key == "up" && dir == "down" || key == "down" && dir == "up" || key == "right" && dir == "left" || key == "left" && dir == "right")
        end
    end
end

update do
    if last_move_time + DELAY < tick
        head = snake[0]

        last_move_time = tick

        if snake.length > 1
            for i in (1..snake.length - 1).to_a.reverse
                snake[i].set_position(Vec2.new(snake[i - 1].pos.x, snake[i - 1].pos.y))
            end
        end
        
        next_pos = nil

        for i in 0..inputs.length - 1
            if inputs[i] == nil || inputs[i] == "up" && dir == "down" || inputs[i] == "down" && dir == "up" || inputs[i] == "right" && dir == "left" || inputs[i] == "left" && dir == "right"
                next
            end
            dir = inputs[i]
            inputs[i] = nil
            break
        end
        
        case dir
        when "up"
            next_pos = Vec2.new(head.pos.x, head.pos.y - 1)
        when "down"
            next_pos = Vec2.new(head.pos.x, head.pos.y + 1)
        when "left"
            next_pos = Vec2.new(head.pos.x - 1, head.pos.y)
        when "right"
            next_pos = Vec2.new(head.pos.x + 1, head.pos.y)
        end
        
        snake.each_with_index do |part, i|
            if i == 0
                next
            end
            
            if next_pos.x == part.pos.x && next_pos.y == part.pos.y
                exit
            end
        end
        
        if next_pos.x < 0 || next_pos.x >= GAME_RES_X || next_pos.y < 0 || next_pos.y >= GAME_RES_Y
            exit
        end
        
        head.set_position(next_pos)

        if next_pos.x == food.pos.x && next_pos.y == food.pos.y
            progress = snake.length % 10
            if progress == 0
                snake_color_1 = snake_color_2
                snake_color_2 = get_rand_col()
            end
            lerp = progress.to_f / 10.0
            color = [snake_color_1[0] * (1 - lerp) + snake_color_2[0] * lerp, snake_color_1[1] * (1 - lerp) + snake_color_2[1] * lerp, snake_color_1[2] * (1 - lerp) + snake_color_2[2] * lerp, 1]
            snake << GameSquare.new(Vec2.new(snake[-1].pos.x, snake[-1].pos.y), color)
            food.set_position(find_new_food_pos(snake))
            food.set_color(snake_color_2)
        end
    end
    
    if !paused
        tick += 1
    end
end

show