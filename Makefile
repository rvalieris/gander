
all: README.md

README.md: gander.ipynb
	jupyter nbconvert --execute --to markdown gander.ipynb --output README
