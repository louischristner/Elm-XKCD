##
## EPITECH PROJECT, 2020
## Elm-XKCD
## File description:
## Makefile (pas très utile mais j'ai un peu la flemme de le faire à la main)
##

CC		=	elm make

SRC		=	src/Main.elm
OUTPUT 	=	main.js

FLAGS	=	--output=$(OUTPUT)

all:
	$(CC) $(SRC) $(FLAGS)

clean:
	rm -f $(OUTPUT)

fclean:	clean

re:	fclean all

.PHONY:	all clean fclean re
