app:
	cd mips-app && make board
	python utils/bin2text.py mips-app/bootloader.bin rom.txt
boot:
	cd mips-boot && make board
	python utils/bin2text.py mips-boot/bootloader.bin rom.txt
clean:
	cd mips-boot && make clean
	cd mips-app && make clean
	-rm rom.txt
    