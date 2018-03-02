#Assembly Language Project - "Space Invaders" Fall 2015 CSUEB
#Prints all 3 rows
#Goes back and forth and drops a row if at screen edge
#prints alive aliens correctly
#Goes right on even rows
#Goes left on odd rows
#Fixed time between frames
#Animated
#Line 160 timer controls how fast the ailens move
#bugs:
#see TODO
		.data
screen:
		.space 81*25
screenEnd:
		.byte 0
#begin TimerInterface
timer.int = 6
timer:	.struct 0xa0000050
flags:	.byte	0
mask:	.byte	0
		.half	0
tAlien:		.word	0	#flag/mask 0x02
tPlayer:		.word	0	#0x04
tBullet:		.word	0	#0x08
tBomb:			.word	0	#0x10
tMotherShip:	.word	0	#0x20
tFrame:		.word	0	#0x40
t7:				.word	0	#0x80
	.data
#end TimerInterface
#begin KeyboardInterface
keyboard.int	=	2
keyboard	.struct 0xa0000000
flags:		.byte	0
mask:		.byte	0
			.half	0
keypress:	.byte	0,0,0
presscon:	.byte	0
keydown:	.half	0
shiftdown:	.byte	0
downcon:	.byte	0
keyup:		.half	0
upshift:	.byte	0
upcon:		.byte	0
	.data
keyPressFlag 	=	0b00000001	#1
keyDownFlag 	=	0b00000010	#2
keyUpFlag 		=	0b00000100	#4
keyShift		=	0b00000001	#1
keyAlt		 	=	0b00000010	#2
keyCtrl 		=	0b00000100	#4
#end KeyboardInterface
#begin DATA
	.data
ScoreFile: .ascii "C:\HighScore.txt"
	#note that this screen image will need to use
	#unalinged memory opertiaons for
linesize =		81
LEFTARROW =		37
RIGHTARROW =	39
SPACEBAR =		32 #this one could be wrong but I can't find it
AlienHeight = 4 #3+1
AlienWidth = 5 #4+1
NumAliens =		11
WordSpaces = 538976288		#0x20202020 all spaces
AlienRowOffset: .word 0
AlienColOffset: .word 0

TopRowAlive:			#if 1 then alive, 0 if dead
		.byte 1:11		#0,1,1,1,0,1,1,0,0,0,0#,0,0,0	#1:11
MidRowAlive:
		.byte 1:11		#0,0,1,1,1,0,1,1,0,0,0#,0,0,0#1:11
BotRowAlive:	
		.byte 1:11		#0,0,0,1,1,1,0,1,1,0,0#,0,0,0#1:11
EndRowAlive:	
		.byte 1:11		#0,0,0,1,1,1,0,1,1,1,0#,0,0,0#1:11
BulletLoc:		.word  0 #screen location
				#.byte  0 #col location

IsBullet: 		.byte 0	 #if bullet is on screen
IsBomb:		.byte 0  #if bomb on screen
Alien1L:	.word 0xdddcdcde,0xbbdbdbc8,0xdd5fdd5f# 0xdedcdcdd,0xc8dbdbbb,0x5fdd5fdd
	#.ascii "ÞÜÜÝ" #dedcdcdd
	#.ascii "ÈÛÛ»" #c8dbdbbb
	#.ascii "_Ý_Ý" #5fdd5fdd
Alien1R:	.word 0xdddcdcde,0xbcdbdbc9,0x5fde5fde#0xdedcdcdd,0xc9dbdbbc,0xde5fde5f
	#.ascii "ÞÜÜÝ" #dedcdcdd
	#.ascii "ÉÛÛ¼" #c9dbdbbc
	#.ascii "Þ_Þ_" #de5fde5f
Defense:	.word 0xdbdbdbdb, 0xdbdbdbdb
			.half 0xdbdb, 0xdbdb   
	#.ascii "ÛÛÛÛÛÛÛÛ" ÜÛÛÛÛÛÛÜ 220 = half size
	#.ascii "ÛÛ    ÛÛ" Û²±° 219 178 177 176
DefenseHP1: .byte 219:48

PlayerShipTop:
	#.word 0xc9dcdbdc
	.word 0xdcdbdcc9
	.byte 0xbb
PlayerShipBot:
	.word 0xdfdfdfdf
	.byte 0xdf
	#.ascii "ÉÜÛÜ»"
	#.ascii "ßßßßß"
PlayerLoc: .byte 25
MotherShip: .word 0xdcdbdbdc,0xdfdbdbdf
	#0xdcdbdbdcÜÛÛÜ 220 219 219 220
	#0xdfdcdcdfßÛÛß 223 219 219 223
MotherShipAlive: .byte 0
Explosion:
	.word 	0x0fddde0f,0xae1313af,0x0fddde0f
Alien2U:
	.ascii "È§§¼"
	.ascii "À²²Ù"
	.ascii "ÜÝÞÜ"
Alien2D:
	.ascii "É§§»"
	.ascii "Ú²²¿"
	.ascii "ÜÝÞÜ"
#begin EndScreen
EndScreen:
	#.ascii "                                                                                \n"
	#.ascii "                                                                                \n"
	.byte 10,10,10
	.ascii "      .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .-.       \n"
	.ascii "    .'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `.     \n"
	.ascii "   (    .     .-.     .-.     .-.     .-.     .-.     .-.     .-.     .    )    \n"
	.ascii "    `.   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   `._.'   .'     \n"
	.ascii "      )    )                   All Time High Score                 (    (       \n"
	.ascii "    ,'   ,'                                                         `.   `.     \n"
	.ascii "   (    (                                                             )    )    \n"
	.ascii "    `.   `.                                                         .'   .'     \n"
	.ascii "      )    )                          Score                        (    (       \n"
	.ascii "    ,'   ,'                                                         `.   `.     \n"
	.ascii "   (    (                                                             )    )    \n"
	.ascii "    `.   `.                                                         .'   .'     \n"
	.ascii "      )    )                       Play Again?                     (    (       \n"
	.ascii "    ,'   ,'                            Y/N                          `.   `.     \n"
	.ascii "   (    (                                                             )    )    \n"
	.ascii "    `.   `.                                                         .'   .'     \n"
	.ascii "      )    )       _       _       _       _       _       _       (    (       \n"
	.ascii "    ,'   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   `.     \n"
	.ascii "   (    '  _  `-'  _  `-'  _  `-'  _  `-'  _  `-'  _  `-'  _  `-'  _  `    )    \n"
	.ascii "    `.   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   .' `.   .'     \n"
	.ascii "      `-'     `-'     `-'     `-'     `-'     `-'     `-'     `-'     `-'       \n"
	.ascii "                                                                                \n"
	.asciiz "                                                                                \n"
#end EndScreen

#end DATA
	.code
#begin ClearScreen	
ClearScreen:
	la		$t0,screen
	addi	$t2,$0,25 #li?
	li		$t3,0x20202020
	addi	$t4,$0,'\n
1:	addi	$t1,$0,4
2:	usw	$t3,0($t0)
	usw	$t3,4($t0)
	usw	$t3,8($t0)
	usw	$t3,12($t0)
	usw	$t3,16($t0)
	addi	$t0,$t0,20
	addi	$t1,$t1,-1
	bgtz	$t1,2b
	sb		$t4,($t0)
	addi	$t0,$t0,1
	addi	$t2,$t2,-1
	bgtz	$t2,1b
	sb		$0,-1($t0)
	jr		$ra
#end ClearScreen
#begin Main
	.globl main
main:
	li	$s0,748		#Alien Move Timer
	li	$s6,5		#player lives
	li	$s7,44		#remaining aliens
	jal StartTimers
	b	Wait		#should probably change name to GameLoop


#end main
#begin StarTimers
StartTimers:
	#alien update timer started
	la 	$a0,timer.tAlien
	li	$a1,4	#haven't got a clue what this does but the book says it so... here it is
	li	$a2,748	#initial wait time for alien timer 17*44
	syscall $IO_write
	
	la 	$a0,timer.tPlayer
	li	$a1,4
	li	$a2,68	#16*4 = 4 frames - player moves once every 4 frames
	syscall $IO_write
	
	la 	$a0,timer.tBullet
	li	$a1,4
	li	$a2,17	#every 1 frames - twice as fast as the player
	syscall $IO_write
	
	la 	$a0,timer.tBomb
	li	$a1,4
	li	$a2,68	#every 5 frames - just as fast as the player
	syscall $IO_write	
	
	la 	$a0,timer.tMotherShip
	li	$a1,4
	li	$a2,4000	#Initially set to 4 seconds
	syscall $IO_write
	
	#frame update timer started
	la 	$a0,timer.tFrame
	li	$a1,4	#no idea
	li	$a2,17	#16ms = 62fps
	syscall $IO_write
	jr	$ra
#end StartTimers
#begin CheckIfHit -- Needs work
#a0 = target toggle(0 = alien, 1 = player, 2 = defense, 3 = mothership)
#a1 =  row of alien
#a2  = col of alien

#ODL a0 = location, a1 = target toggle(0 = alien, 1 = player, 2 = defense, 3 = mothership)
CheckIfHit:
	beq		$a0,3,MotherShipHit
	beq		$a0,2,DefenseHit
	beq		$a0,1,PlayerHit
#begin AlienHit
AlienHit:	#else		#loads the 3 words below it to check if they're all spaces or not
			#might have to calculate bullet location and alien location
			#or check all 12 pixels every time (this option would suck for performance but easiest implementation)
	
	# if bomb is less than 32 then the whole number will go down
	# so that means it's an alien bomb so don't kill alien
	#but if the number goes up then that means it's my bullet so kill alien
	li	$t9,0x02020202
	ulw $t0,($t1)
	srl	$t0,$t0,4
	bgt $t0,$t9,isHitA
	ulw $t0,81($t1)
	srl	$t0,$t0,4
	bgt $t0,$t9,isHitA
	ulw $t0,162($t1)
	srl	$t0,$t0,4
	bgt $t0,$t9,isHitA

	b	notHit
isHitA:

	addi	$s0,$s0,-17
	addi 	$s5,$s5,50			#aliens are worth 50 points
	addi	$s7,$s7,-1	#s7 = aliens alive
#end AlienHit
DefenseHit:
	
MotherShipHit:

PlayerHit:

isHit:
	la	$t0,IsBullet
	sb	$0,($t0)
	li	$v0,1
	b	CIHEnd
notHit:
	li	$v0,0
CIHEnd:
	jr		$ra
#end CheckIfHit
#begin MoveMyShip
#a0 = address , #a1 = bytes to read or mask or...I forget, it's a magic number
MoveMyShip:   
	li	$a0,keyboard.flags 
	#la	$a1,keyPressFlag				#for A D keys
	la	$a1,keyDownFlag
	li	$v0,0
	syscall $IO_read
	#andi	$t1,$v0,keyPressFlag		#for A D keys
	andi	$t1,$v0,keyDownFlag
	beqz	$t1,NoKey	#if key not pressed go to ends
	addi	$a0,$a0,8
	syscall $IO_read

	#beq		$v0,97,lArr				#for A D keys
	#beq		$v0,100,rArr			#for A D keys
	beq		$v0,LEFTARROW,lArr
	beq		$v0,RIGHTARROW,rArr
	beq		$v0,SPACEBAR,fire
	b	NoKey
fire:
	addi	$sp,$sp,-4
	sw		$ra,($sp)
	#jal		SaveEverything			---------Edit this function
	jal		FireBullet
	#jal		RestoreEverything			---------Edit this function
	lw		$ra,($sp)
	addi	$sp,$sp,4
	b		MMSEnd
rArr:
	li $s2,1
	la	$t0,PlayerLoc
	lbu	$t1,($t0)		#int value of player location
	bge	$t1,75,MMSEnd	#75 is as far right as it can go before going over the edge
	addi $t1,$t1,1
	sb	$t1,($t0)
	b	MMSEnd
lArr:
	li $s2,-1
	la	$t0,PlayerLoc
	lbu	$t1,($t0)
	beqz	$t1,MMSEnd	#if it's 0 then it's at the far left edge and can't go further
	addi $t1,$t1,-1
	sb	$t1,($t0)
	b MMSEnd
	#if keydown then do stuff
	#if left arrow playerloc -1
	#	if player loc = 0 do nothing
	#if right arrow playerloc +1
	#	if player loc = 75 do nothing
NoKey:
	li $s2,0
MMSEnd:
	jr	$ra
#end MoveMyShip
#begin FireBullet
FireBullet:
	la	$t0,IsBullet
	lb	$t1,($t0)	#0 if no bullet, 1 if bullet
	bnez $t1,FBEnd #if not zero, thus 1 then there is a bullet already on screen
					#so go to the ends of the function because you can't fire another
	
	li	$t1,1
	sb	$t1,($t0)	#sets IsBullet to true
	
	li	$t1,81*23	#24th row
	
	la	$t2,PlayerLoc
	lbu	$t2,($t2)		#integer position of player
	addi	$t2,$t2,2	#center of ship
	add	$t1,$t1,$t2	#distance from start
	la	$t0,BulletLoc
	sw	$t1,($t0)		#stores distance in bullet loc
	la	$t0,screen
	add	$t0,$t0,$t1	#t0 = location on screen
	li		$t1,186 #186 = º, 179 = ³
	sb		$t1,($t0)
FBEnd:
	jr	$ra
#end FireBullet -- New
#begin PutMyBullet
#PUT BULLET DONE#####################
PutMyBullet:
	la	$t0,IsBullet
	lbu	$t0,($t0)		#0 if no bullet, 1 if bullet
	beqz	$t0,PBEnd	#If 0, aka no bullet, go to ends
	la	$t0,BulletLoc
	lw	$t0,($t0)		#t1 = absolute location of bullet
	la	$t1,screen
	add	$t0,$t0,$t1	#absolute location + screen
	li	$t2,186		#186 = º, 179 = ³
	sb	$t2,($t0)
PBEnd:
	jr	$ra
#####################################
#end PutMyBullet -- New
#begin MoveBullet
#MOVE BULLET DONE####################
MoveBullet:
	la		$t0,IsBullet
	lbu		$t1,($t0)		#0 if no bullet, 1 if bullet
	beqz 	$t1,MBEnd		#If 0, aka no bullet, go to ends
	la		$t1,BulletLoc
	lw		$t2,($t1)		#t2 = absolute location
	addi	$t2,$t2,-81	#t2 = next absolute location
	sw		$t2,($t1)		#store next absolute location in BulletLoc
	bgtz	$t2,MBEnd		#essentially if bullet has not gone above the screen yet
	sb		$0,($t0)		#if it has, set isBullet to 0, aka false, aka no bullet
MBEnd:
	jr	$ra
#MOVE BULLET DONE####################
#end MoveBullet -- New
#begin PutMyShip
PutMyShip:
	la	$t0,screen
	addi	$t0,$t0,81*23	#24th row because ship is 2 tall
	la	$t1,PlayerLoc		#player location offset
	lbu	$t1,($t1)
	add	$t0,$t0,$t1			#screen + location offset
	
	ulw $t1,($t0)
	li $t2,0x20202020
	blt $t1,$t2,gotHit
	ulw $t1,81($t0)
	blt $t1,$t2,gotHit
	lbu $t1,4($t0)
	blt $t1,32,gotHit
	lbu $t1,85($t0)
	blt $t1,32,gotHit
	
	la	$t1,PlayerShipTop
	lw	$t2,($t1)
	usw	$t2,($t0)	#store first part
	lbu	$t2,4($t1)
	sb	$t2,4($t0)	#store 5th char of top of ship
	
	addi	$t0,$t0,81
	la	$t1,PlayerShipBot
	lw	$t2,($t1)
	usw	$t2,($t0)	#store first part
	lbu	$t2,4($t1)
	sb	$t2,4($t0)	#store 5th char of top of ship
	b PMSEnds
gotHit:
	addi	$s6,$s6,-1		#-1 lives
	la $t0,PlayerLoc
	li $t1,9
	sb $t1,($t0)
	la $t0,IsBomb
	sb	$0,($t0)	#no bomb
PMSEnds:	
	jr	$ra
#end PutMyShip
#begin PutDefense	-- IT WORKS!!!
PutDefense:
	li		$t0,81*21 	#row to start on
	addi 	$t0,$t0,9	#starting location
	la		$t1,screen
	add		$t0,$t0,$t1
	la		$t1,DefenseHP1
	la		$t2,IsBomb
	la		$t3,IsBullet
	
	
	#t0 = starting location on screen
	#t1 = Defense HP array start
	#t2 = IsBullet
	#t3 = IsBomb
	li	$t7,4
BDTLoop:
	li	$t6,8
DTLoop:
	lbu		$t4,($t1)		#checks health
	beqz	$t4,nextHP		#if zero then don't do anything and skip to next one
	lbu		$t5,($t0)		#load character on screen
	beq		$t5,32,DSEmpty		#if it's a space it's empty
	beq		$t5,15,DBomb		#if it's a bomb it's a bomb
	beq		$t5,186,DBullet	#if it's 186 it's my bullet
	b		DAlien				#if it's none of the above, the only answer is an alien
DBomb:
	sb	$0,($t2)	#first thing, set the bomb to disappear
	b DGotHit
DBullet:
	sb	$0,($t3)	#first thing, set the bullet to disappear
	b DGotHit
DAlien:
	sb		$0,($t1) #sets the health of the defense in question to completely dead and don't print anything
	b		nextHP
DSEmpty:		#defense character on screen empty
	move	$t5,$t4
	b		SPrint
DGotHit:
	addi	$t4,$t4,-1		#subtract 1 from hp of defense
	blt 		$t4,179,lower				#if defense hp is still greater than 178 that means it was new so set it to 178
	li		$t4,178
	b		SPrint
lower:
	bgt		$t4,175,SPrint					#Û²±° 219 178 177 176
	mov	$t4,$0					#if less than or equal to 175 it's dead
	sb		$t4,($t1)				#store zero in array and print blank space this frame
	li		$t4,32
	sb		$t4,($t0)
	b		nextHP
SPrint:
	sb		$t4,($t1)				#store and print the new value
	sb		$t4,($t0)
nextHP:
	addi	$t0,$t0,1		#moves screen pointer forward
	addi	$t1,$t1,1		#moves defense pointer forward
	addi	$t6,$t6,-1		#loop counter for top row
	bgtz	$t6,DTLoop
	
	addi	$t0,$t0,73		#Goes to next line

	li	$t6,2
DTLoop2:
	lbu		$t4,($t1)		#checks health
	beqz	$t4,nextHP2		#if zero then don't do anything and skip to next one
	lbu		$t5,($t0)
	beq		$t5,32,DSEmpty2	#if it's a space it's empty
	beq		$t5,15,DBomb2		#if it's a bomb it's a bomb
	beq		$t5,186,DBullet2	#if it's 186 it's my bullet
	b		DAlien2				#if it's none of the above, the only answer is an alien
DBomb2:
	sb	$0,($t2)	#first thing, set the bomb to disappear
	b DGotHit2
DBullet2:
	sb	$0,($t3)	#first thing, set the bullet to disappear
	b DGotHit2
DAlien2:
	sb		$0,($t1) #sets the health of the defense in question to completely dead and don't print anything
	b		nextHP2
DSEmpty2:		#defense character on screen empty
	move	$t5,$t4
	b		SPrint2
DGotHit2:
	addi	$t4,$t4,-1		#subtract 1 from hp of defense
	blt 		$t4,179,lower2				#if defense hp is still greater than 178 that means it was new so set it to 178
	li		$t4,178
	b		SPrint2
lower2:
	bgt		$t4,175,SPrint2					#Û²±° 219 178 177 176
	mov	$t4,$0							#if less than or equal to 175 it's dead
	sb		$t4,($t1)				#store zero in array and print blank space this frame
	li		$t4,32
	sb		$t4,($t0)
	b		nextHP2
SPrint2:
	sb		$t4,($t1)				#store and print the new value
	sb		$t4,($t0)
nextHP2:
	addi	$t0,$t0,1		#moves screen pointer forward
	addi	$t1,$t1,1		#moves defense pointer forward
	addi	$t6,$t6,-1		#loop counter for top row
	bgtz	$t6,DTLoop2
	
	addi	$t0,$t0,4		#Goes to next location

	li	$t6,2
DTLoop3:
	lbu		$t4,($t1)		#checks health
	beqz	$t4,nextHP3		#if zero then don't do anything and skip to next one
	lbu		$t5,($t0)
	beq		$t5,32,DSEmpty3		#if it's a space it's empty
	beq		$t5,15,DBomb3		#if it's a bomb it's a bomb
	beq		$t5,186,DBullet3	#if it's 186 it's my bullet
	b		DAlien3				#if it's none of the above, the only answer is an alien
DBomb3:
	sb	$0,($t2)	#first thing, set the bomb to disappear
	b DGotHit3
DBullet3:
	sb	$0,($t3)	#first thing, set the bullet to disappear
	b DGotHit3
DAlien3:
	sb		$0,($t1) #sets the health of the defense in question to completely dead and don't print anything
	b		nextHP3
DSEmpty3:		#defense character on screen empty
	move	$t5,$t4
	b		SPrint3
DGotHit3:
	addi	$t4,$t4,-1		#subtract 1 from hp of defense
	blt 		$t4,179,lower3				#if defense hp is still greater than 178 that means it was new so set it to 178
	li		$t4,178
	b		SPrint3
lower3:
	bgt		$t4,175,SPrint3					#Û²±° 219 178 177 176
	mov	$t4,$0							#if less than or equal to 175 it's dead
	sb		$t4,($t1)				#store zero in array and print blank space this frame
	li		$t4,32
	sb		$t4,($t0)
	b		nextHP3
SPrint3:
	sb		$t4,($t1)				#store and print the new value
	sb		$t4,($t0)
nextHP3:
	addi	$t0,$t0,1		#moves screen pointer forward
	addi	$t1,$t1,1		#moves defense pointer forward
	addi	$t6,$t6,-1		#loop counter for top row
	bgtz	$t6,DTLoop3
	
	addi	$t0,$t0,-71
	addi	$t7,$t7,-1
	bgtz	$t7,BDTLoop
	jr	 $ra
#put defenses but check if defense hit before rendering
#end Put Defense
#begin MoveAliens
#a0 = screen, a1= row offset number, a2= col off set number
MoveAliens:
	addi $sp,$sp,-4
	sw	$ra,($sp)
	#move aliens 1 column
	andi $t2,$a1,1
	bgtz $t2,oddRow	
evenRow:
	jal getFarRight	#v0 = index of furthest right
						#uses t0-7
	addi $v0,1
	mul $v0,$v0,5
	add $v0,$v0,$a2	#adds column offset to furthest right printed character
						#if over 80 then go down a row and don't add a column
	bgt $v0,80,Down
	addi $a2,$a2,1	 	#even row moves right
	b MAEnd
oddRow:	
	jal getFarLeft		#v0 = index of furthest left
	mul $v0,$v0,5
	sub $v0,$0,$v0
	bge	$v0,$a2,Down
	addi $a2,$a2,-1	#odd row moves left
	b MAEnd
Down:
	la	$t0,AlienRowOffset
	addi $a1,$a1,1
	sw	$a1,($t0)
MAEnd:
	la	$t0,AlienColOffset
	sw	$a2,($t0)
	lw	$ra,($sp)
	addi $sp,$sp,4
	jr	$ra
#end MoveAliens
#begin Wait			--Should rename GameLoop
Wait:
##    ÛÛÛÛÛÛÛÛ» ÛÛÛÛÛÛ» ÛÛÛÛÛÛ»  ÛÛÛÛÛÛ»     	##
##    ÈÍÍÛÛÉÍÍ¼ÛÛÉÍÍÍÛÛ»ÛÛÉÍÍÛÛ»ÛÛÉÍÍÍÛÛ»    	##
##       ÛÛº   ÛÛº   ÛÛºÛÛº  ÛÛºÛÛº   ÛÛº    	##
##       ÛÛº   ÛÛº   ÛÛºÛÛº  ÛÛºÛÛº   ÛÛº    	##
##       ÛÛº   ÈÛÛÛÛÛÛÉ¼ÛÛÛÛÛÛÉ¼ÈÛÛÛÛÛÛÉ¼    	##
##       ÈÍ¼    ÈÍÍÍÍÍ¼ ÈÍÍÍÍÍ¼  ÈÍÍÍÍÍ¼     	##
##    ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ    	##
##	  Fix the mothership crap			 		##
##	 										      	##
##  										      	##
	addi	$sp,$sp,-4
	sw		$ra,($sp)
	li	$a1,1
waitLoop:
	la	$a0,timer.flags
	syscall	$IO_read
	addi	$sp,$sp,-16
	sw		$a0,($sp)
	sw		$v0,4($sp)
	sw		$a1,8($sp)
	sw		$a2,12($sp)
	#begin alien 		-- MoveAliens, a2 = colInteger
	andi	$t0,$v0,0x02	
	beqz	$t0,1f		#if timer is not up then check next timer
						#else reset timer and do function
	#store things on the stack

	#load arguments
	la 	$a0,screen
	la 	$a1,AlienRowOffset
	lw 	$a1,($a1)
	la	$a2,AlienColOffset
	lw	$a2,($a2)
	#call move aliens
	jal		MoveAliens
	#reset timer
	la		$a0,timer.tAlien
	syscall $IO_read
	li		$a1,4
	mov	$a2,$s0
	syscall $IO_write
	#restore items from stack and move sp back
	lw	$a0,($sp)
	lw	$v0,4($sp)
	lw	$a1,8($sp)
	lw	$a2,12($sp)
#end alien
1:	#begin Player		-- MoveMyShip
	andi	$t0,$v0,0x04
	beqz	$t0,2f		#if timer is not up then check next timer
						#else reset timer and do function
	jal MoveMyShip
	la		$a0,timer.tPlayer
	syscall $IO_read
	
	lw	$a0,($sp)
	lw	$v0,4($sp)
	lw	$a1,8($sp)
	lw	$a2,12($sp)
#end Player
2:	#begin Bullet		-- MoveBullet
	andi	$t0,$v0,0x08
	beqz	$t0,3f		#if timer is not up then check next timer
						#else reset timer and do function
	jal MoveBullet
	#something is wrong with move bullet
	la		$a0,timer.tBullet
	syscall $IO_read
	lw	$a0,($sp)
	lw	$v0,4($sp)
	lw	$a1,8($sp)
	lw	$a2,12($sp)
#end Bullet
3:	#begin Bomb 		-- MoveBomb
	andi	$t0,$v0,0x10
	beqz	$t0,4f		#if timer is not up then check next timer
						#else reset timer and do function
	jal FireBomb
	jal MoveBomb
	la		$a0,timer.tBomb
	syscall $IO_read
	lw	$a0,($sp)
	lw	$v0,4($sp)
	lw	$a1,8($sp)
	lw	$a2,12($sp)
#end Bomb
4:	#begin Mothership	-- Move/Spawn MotherShip
	andi	$t0,$v0,0x20
	beqz	$t0,5f		#if timer is not up then check next timer
						#else reset timer and do function
	la 	$a0,timer.tMotherShip
	syscall $IO_read			#First thing I do is reset it
	
	#s3 = alive
	beqz	$s3,SpawnMotherShip		#if no ship on screen spawn one
	jal MoveMotherShip					#otherwise move it
	b	SMSEnd
SpawnMotherShip:
	la	$t0,AlienRowOffset
	lw	$t0,($t0)
	blt	$t0,2,SMSEnd			#if not on row 2 yet then just jump to the ends
	li	$s3,1		#sets alive to true
	li	$s4,0		#sets position to left 
	
	la 	$a0,timer.tMotherShip
	li	$a1,4
	li	$a2,128		#set to every 8 frames(half speed of player)
	syscall $IO_write

	#b	5f
SMSEnd:
#	la		$a0,timer.tMotherShip
#	syscall $IO_read
#end MotherShip
5:	lw	$a0,($sp)
	lw	$v0,4($sp)
	lw	$a1,8($sp)
	lw	$a2,12($sp)
	addi	$sp,$sp,16
#begin Frame		-- RenderFrame 
	andi	$t0,$v0,0x40
	beqz	$t0,waitLoop	
	jal		RenderFrame
	la		$a0,timer.tFrame
	syscall $IO_read
#end Frame
	
	bgtz	$s7,goc
	jal		ResetAliens
goc: #s6 = lives
	blez	$s6,GameOver
	b		waitLoop
endWait:
	lw		$ra,($sp)
	addi	$sp,$sp,4
	jr		$ra
#end Wait
#begin GameOver
GameOver:
	#s6 =lives
	#s5 = score
	la	$a0,EndScreen
	syscall	$print_string
	li $a0,38
	li $a1,11		#38 / 11 for current score 
					#38 / 7 for high score
	syscall $xy
	move	$a0,$s5	
	syscall $print_int	#print current game score
	
	#get high score from file
	
	#
	
	li $a0,38
	li $a1,7		
	syscall $xy
	move	$a0,$s5	
	syscall $print_int	#prints high score
	li $s3,0
#end GameOver
#begin PlayAgain
PlayAgain:
		li	$a0,keyboard.flags 
		la	$a1,keyDownFlag
KeyCheck:

	syscall $IO_read
	andi	$t1,$v0,keyDownFlag
	beqz	$t1,KeyCheck	#if key not pressed recheck
							#because god damnit I know you want to play again
	addi	$a0,$a0,8
	syscall $IO_read
	addi	$a0,$a0,-8

	beq		$v0,'Y,Yes
	beq		$v0,'N,No
	b	KeyCheck
	
Yes:	
	jal ClearScreen
	la	$a0,screen
	syscall $print_string
	jal ResetAliens
	b ResetGame
No:
	syscall $exit
#end PlayAgain
#begin ResetGame
ResetGame:	#I'm not sure what's wrong but here I'm going to manually reset every single register and data segment	
	la	$t0,IsBullet			#b
	sb	$0,($t0)
	la	$t0,IsBomb				#b
	sb	$0,($t0)
	la	$t0,AlienRowOffset	#w
	sw	$0,($t0)
	la	$t0,AlienColOffset	#w
	sw	$0,($t0)
	la	$t0,PlayerLoc			#b25
	li	$t1,25
	sb	$t1,($t0)
	la	$t0,MotherShipAlive	#b
	sb	$0,($t0)
	la	$t0,DefenseHP1		#b 219:48
	li	$t1,0xDBDBDBDB
	li	$t2,12
ResetDef:
	usw	$t1,($t0)
	addi	$t0,$t0,4
	addi	$t2,$t2,-1
	bnez	$t2,ResetDef
	jal ClearScreen
	li $a0,0
	li $a1,0	
	syscall $xy
	
	la	$a1,4
	la	$a2,0
	la	$a0,timer.tAlien
	syscall $IO_write	#alien
	syscall $IO_read
	addi $a0,$a0,4
	syscall $IO_write	#bullet
	syscall $IO_read
	addi $a0,$a0,4
	syscall $IO_write	#bomb
	syscall $IO_read
	addi $a0,$a0,4
	syscall $IO_write	#ship
	syscall $IO_read
	addi $a0,$a0,4
	syscall $IO_write	#frame
	syscall $IO_read

tFrame:
	li $t0,0
	li $t1,0
	li $t2,0
	li $t3,0
	li $t4,0
	li $t5,0
	li $t6,0
	li $t7,0
	li $t8,0
	li $t9,0
	li $s0,0
	li $s1,0
	li $s2,0
	li $s3,0
	li $s4,0
	li $s5,0
	li $s6,0
	li $s7,0
	li $a0,0
	li $a1,0
	li $a2,0
	li $a3,0
	li $v0,0
	li $v1,0
	b main
#end ResetGame
#begin RenderFrame
RenderFrame:#oh god kill me now
	addi	$sp,$sp,-4
	sw		$ra,($sp)
	jal	ClearScreen
	jal	PutMyBullet
	la 	$a0,screen
	la 	$a1,AlienRowOffset
	lw 	$a1,($a1)
	la	$a2,AlienColOffset
	lw	$a2,($a2)
	jal	PutAllAliens
	jal PutMotherShip
	jal  PutBomb
	jal PutDefense
	jal PutMyShip		#Uses t0 - t2
	la	$a0,screen
	syscall $print_string
	lw	$ra,($sp)
	addi	$sp,$sp,4
	jr	$ra
#end RenderFrame
#begin PutAlienRow
#a0 = screen buffer, a1 = Row offset integer, a2 = Col offset integer, a3 = row printing alive array
PutAlienRow:
	li		$t0,10	#number of aliens-1
PAlienloop:
	#if alien in row alive then do this else jump back again
	#mov	$t4,$a3
	add		$t4,$a3,$t0	#array + index offset
	lbu		$t4,($t4)
	blez		$t4,iterate	#if alien not alive go to next alien in list
	sll		$t1,$t0,2		#base offset on line
	add		$t1,$t1,$t0		#multiplies by 5 because each alien is 5 characters apart
	la		$t3,linesize
	#Multiplies by 81
	# could do  add (sll $t3 6 + sll $t3 4) + $t3  for 4 operations instead of 32
	mul 	$t2,$a1,$t3		#multiplies row offset by 81 to get how much further to go
	add		$t2,$t2,$a2		#adds column offset
	add		$t1,$t2,$t1 	#full screen offset for last alien
	add		$t1,$t1,$a0		#location address on screen now

	la		$t5,IsBullet
	lbu		$t5,($t5)
	beqz	$t5,cont		#no bullet on screen, don't bother checking if hit
	
	addi	$sp,$sp,-24
	sw		$a0,($sp)
	sw		$ra,4($sp)		#store a0,a1 and ra on stack
	sw		$t0,8($sp)
	sw		$t1,12($sp)
	sw		$a1,16($sp)
	sw		$a2,20($sp)
	li		$a0,0			#0 = checking alien
	jal		CheckIfHit		#v0 = 1 if hit, 0 if not
	lw		$a0,($sp)
	lw		$ra,4($sp)
	lw		$t0,8($sp)
	lw		$t1,12($sp)
	lw		$a1,16($sp)
	lw		$a2,20($sp)
	addi	$sp,$sp,24		#restore previous values
	
	#b		cont
	beqz	$v0,cont		#if it is zero then not hit continue as normal
	add		$t4,$a3,$t0		#else gets the location in the array
	sb		$0,($t4)		#sets it to dead
	
	##PRINT EXPLOSION HEREs
	la		$t2,Explosion
	lw		$t3,0($t2)
	usw		$t3,0($t1)
	lw		$t3,4($t2)
	usw		$t3,81($t1)
	lw		$t3,8($t2)
	usw		$t3,162($t1)
	
	b		iterate			#skips over printing alien
cont:
	andi	$t6,$a2,1
	beqz	$t6,A1		#odd col do left facing
	la		$t2,Alien1R	#even col do right facing
	b		Store
A1:	la	 	$t2,Alien1L
	#stores alien 
Store:
	lw		$t3,0($t2)
	usw		$t3,0($t1)
	lw		$t3,4($t2)
	usw		$t3,81($t1)
	lw		$t3,8($t2)
	usw		$t3,162($t1)
iterate:
	addi 	$t0,$t0,-1
	bgez	$t0,PAlienloop
	jr		$ra
#end PutAliens
#begin getFarRight -- gets index of right most alive alien. Possibly change to more effcient
getFarRight:			
	li	$t0,10		#this is NumAliens-1
	la	$t1,TopRowAlive
	la	$t2,MidRowAlive	#mid row
	la	$t3,BotRowAlive	#bot row
	la	$t8,EndRowAlive #Definitely the bottom row
	addi $t1,NumAliens-1				#far right
	addi $t2,NumAliens-1
	addi $t3,NumAliens-1				#far right
	addi $t8,NumAliens-1
gFRLoop:
	lbu $t5,($t1)		#far right top row alive
	lbu $t6,($t2)		#far right mid row alive
	lbu $t7,($t3)		#far right bot row alive
	lbu $t9,($t8)		#Definitely far right last bottom ends final row thing
	or $t4,$t5,$t6	
	or $t4,$t4,$t9
	or $t4,$t4,$t7	#ands all 3 rows, if anything is a 1 then it'll be 1 meaning there a live alien there
	addi $t1,$t1,-1	#moves all 3 column pointers backwards
	addi $t2,$t2,-1
	addi $t3,$t3,-1
	addi $t8,$t8,-1
	addi $t0,$t0,-1
	beqz	$t4,gFRLoop
	#li	$v0,0
	addi $v0,$t0,1
	jr	$ra
#end getFarRight
#begin getFarLeft -- gets index of leftmost alive alien		"		 "		 "	 	 "  	   "
getFarLeft:
	li	$t0,0
	la	$t1,TopRowAlive
	la	$t2,MidRowAlive	#mid row
	la	$t3,BotRowAlive	#bot row
	la	$t8,EndRowAlive #Definitely the bottom row
gFLLoop:
	lbu $t5,($t1)		#far left top row alive
	lbu $t6,($t2)		#far left mid row alive
	lbu $t7,($t3)		#far left bot row alive
	lbu $t9,($t8)		#Definitely far right last bottom ends final row
	or $t4,$t5,$t6	
	or $t4,$t4,$t7
	or $t4,$t4,$t9
	addi $t1,$t1,1		#moves all 3 column pointers forward
	addi $t2,$t2,1
	addi $t3,$t3,1
	addi $t8,$t8,1
	addi $t0,$t0,1
	beqz $t4,gFLLoop
	#li	$v0,0
	addi $v0,$t0,-1
	jr	$ra
#end getFarLeft
#begin PutAllAliens
PutAllAliens:
	addi $sp,$sp,-4
	sw	 $ra,($sp)
	
	la	$a3,TopRowAlive
	jal	PutAlienRow
	
	addi $a1,$a1,4
	la	$a3,MidRowAlive
	jal	PutAlienRow
	
	addi $a1,$a1,4
	la	$a3,BotRowAlive
	jal	PutAlienRow
	
	addi $a1,$a1,4
	la	$a3,EndRowAlive
	jal	PutAlienRow
	
	addi $a1,$a1,-12
	lw	$ra,($sp)
	addi $sp,$sp,4
	jr	$ra
#end PutAllAliens
#begin MoveBomb 
MoveBomb:
	la	$t0,IsBomb
	lbu	$t1,($t0)
	beqz	$t1,EMoveBomb	#if no bomb go to ends of function

	addi	$s1,$s1,81			#moves down 1 line
	li		$t4,2025
	slt		$t3,$s1,$t4		#1 if on screen
	bnez	$t3,EMoveBomb		#if on screen go to end, else set IsBomb to false
	sb		$0,($t0)				#else set IsBomb to 0(False)
EMoveBomb:
	jr	$ra
#end MoveBomg
#begin PutBomb
PutBomb:
	la	$t0,IsBomb
	lbu	$t1,($t0)
	beqz	$t1,EPutBomb	#if no bomb then don't put bomb on screen
	
	la $t0,screen
	add $t0,$t0,$s1		#screen + bomb offset
	li	$t1,0xF			#e8 is my bomb character
	sb	$t1,($t0)
EPutBomb:
	jr	$ra
#end PutBomb
#begin FireBomb
FireBomb:
################################################################
################################################################

#calculate location of ship and check every slot directly above it to see if there is a bomb there
#specifically a bomb and not just anything(could be a bullet) draw it at first location unless
#it goes above the screen, then don't draw it at all

#assume ailen is 10 above, they move at same speed of ship.
#if moving right check above 10 spaces right
#if moving left check above 10 spaces left

#start checking above defenses (1620+ship location) +-10
#################################################################
#################################################################
	la	$t0,IsBomb
	lbu	$t1,($t0)
	beq	$t1,1,PEndB	#if already a bomb jump to ends
	li $t1,1
	sb $t1,($t0)		#sets to isbomb to true
	
	la $t0,PlayerLoc
	lbu $t0,($t0)
	addi $t0,$t0,1623
	la $t2,screen
	
	bltz		$s2,mLeft
	bgtz	$s2,mRight
	
	#check if moving here
	#if moving left branch left
	#if moving right branch right
	#otherwise do this

Still:	
cLoop:
	add $t3,$t0,$t2			#t3 = locatin + screen
	lbu $t1,($t3)
	addi $t0,$t0,-81
	addi	$t7,$0,'\n
	beq $t1,$t7,RandBomb		#it's at the new line character
	bne $t1,32,EFireBomb		#if loation isn't a space then it's an alien so fire bomb
	
	bgt $t0,162,cLoop				#if the location is still on the screen, keep checking
	
	b RandBomb					#if it made if off the screen then fire a random bomb
	
mLeft:
	addi $t0,$t0,-9
LCLoop:
	add $t3,$t0,$t2			#t3 = locatin + screen
	lbu $t1,($t3)
	addi	$t7,$0,'\n
	beq $t1,$t7,RandBomb		#it's at the new line character
	addi $t0,$t0,-81
	bne $t1,32,EFireBomb		#if loation isn't a space then it's an alien so fire bomb
	bgt $t0,162,LCLoop				#if the location is still on the screen, keep checking
	b RandBomb					#if it made if off the screen then fire a random bomb
	
mRight:
	addi $t0,$t0,9
RCLoop:
	add $t3,$t0,$t2			#t3 = locatin + screen
	lbu $t1,($t3)
	addi $t0,$t0,-81
	addi	$t7,$0,'\n
	beq $t1,$t7,RandBomb		#it's at the new line character
	bne $t1,32,EFireBomb		#if loation isn't a space then it's an alien so fire bomb
	bgt $t0,162,RCLoop				#if the location is still on the screen, keep checking
	b RandBomb					#if it made if off the screen then fire a random bomb
	
RandBomb:
	la $t4,IsBomb
	#li	$t1,1
	sb	$0,($t4)	#no bomb
	b EFireBomb
PEndB:
	move $t0,$s1
EFireBomb:
	#lw $ra,($sp)
	#addi $sp,$sp,4
	move $s1,$t0
	jr	$ra
#end FireBomb
#begin MoveMotherShip
MoveMotherShip:
	la 	$a0,timer.tMotherShip
	beqz	$s3,MMotherEnd	#if no ship jump to ends
	addi 	$s4,$s4,1			#moves ship right
	blt 		$s4,77,MMotherEnd	#if ship is on screen, continue; else
	li		$s4,0		#ship location reset
	li		$s3,0		#ship not alive
	
	la 	$a0,timer.tMotherShip
	li	$a1,4
	syscall $random		#v0 = random number
	li		$t0,5000
	divu	$v0,$t0	#gets number mod 5000 so any number between 0 and 5 seconds
	mfhi	$v0			#moves it to v0
	add		$a2,$v0,$t0	#a2	now equals that random number + 5000 so any number between 5k and 10k. 5-10 seconds
	syscall $IO_write
MMotherEnd:
	jr	$ra
#end MoveMotherShip
#begin PutMotherShip
PutMotherShip:
#s3 = alive
#s4 = location
	beqz $s3,PMotherShipEnd		#if no ship jump to ends
									#so there is a ship, now check if it's hit
	la	$t0,screen
	add $t0,$t0,$s4
	#t0 = location on screen to print ship
	ulw		$t1,($t0)
	bne		$t1,WordSpaces,MotherShipIsHit	#if not blank then hit jump to hit
	ulw		$t1,81($t0)
	bne		$t1,WordSpaces,MotherShipIsHit	#if not blank then hit jump to hit
	#it got here so it's not hit so now draw it
	la	$t1,MotherShip
	#print at t0
	lw		$t2,($t1)
	usw	$t2,($t0)
	#add 81, print bottom half
	lw		$t2,4($t1)
	usw	$t2,81($t0)
	b	PMotherShipEnd
MotherShipIsHit:
	addi	$s5,200		#200 points for mothership... random? nah
	li		$s3,0	#set mothership to dead
	la 	$a0,timer.tMotherShip
	syscall $IO_read
	li	$a1,4
	syscall $random		#v0 = random number
	li		$t0,5000
	divu	$v0,$t0	#gets number mod 5000 so any number between 0 and 5 seconds
	mfhi	$v0			#moves it to v0
	add		$a2,$v0,$t0	#a2	now equals that random number + 5000 so any number between 5k and 10k. 5-10 seconds
	syscall $IO_write
PMotherShipEnd:
	jr	$ra
#end PutMotherShip
#begin ResetAliens
ResetAliens:
	#s7  = num aliens alive
	li $s7,44
	la $t0,TopRowAlive
	li $t1,11
	li $t2,0x01010101
ResetLoop:
	usw	$t2,($t0)
	addi $t0,4
	addi $t1,$t1,-1
	bnez $t1,ResetLoop
	
	li $s0,744	#4 less soevery 4 frames with the last alien it'll jump 2
				#characters instead of 1... gotta make it harder somehow
	li	$s3,0	#mothership dead so it doesn't continue to move across after reset
				#if alive when last alien dies
	la $t0,AlienColOffset
	sw	$0,($t0)
	la $t0,AlienRowOffset
	sw	$0,($t0)
	jr $ra
#end ResetAliens




## ÛÛÛ»   ÛÛ» ÛÛÛÛÛÛ» ÛÛÛÛÛÛÛÛ»ÛÛÛÛÛÛÛ»ÛÛÛÛÛÛÛ» ##
## ÛÛÛÛ»  ÛÛºÛÛÉÍÍÍÛÛ»ÈÍÍÛÛÉÍÍ¼ÛÛÉÍÍÍÍ¼ÛÛÉÍÍÍÍ¼ ##
## ÛÛÉÛÛ» ÛÛºÛÛº   ÛÛº   ÛÛº   ÛÛÛÛÛ»  ÛÛÛÛÛÛÛ» ##
## ÛÛºÈÛÛ»ÛÛºÛÛº   ÛÛº   ÛÛº   ÛÛÉÍÍ¼  ÈÍÍÍÍÛÛº ##
## ÛÛº ÈÛÛÛÛºÈÛÛÛÛÛÛÉ¼   ÛÛº   ÛÛÛÛÛÛÛ»ÛÛÛÛÛÛÛº ##
## ÈÍ¼  ÈÍÍÍ¼ ÈÍÍÍÍÍ¼    ÈÍ¼   ÈÍÍÍÍÍÍ¼ÈÍÍÍÍÍÍ¼ ##
## ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ##
	#if on even row go right###
		#if right guy is within 5 of end of row go down a row
	#if on odd row go left
		#if left guy is going to be at the edge go down a row
		
	#if offset is greater negative than the absolute value of 
	#than the furthest left * 5 then it's at the boarder
	
	### method for furthest right###
	
	#Check each top mid bot row alive:
	#start at end and go backwards	or all 3 into a register
	#if the result is 1 then there is an alien in that column
	#return that column as last alien
	
	#Same for furthest left start at 0 and or all of them
	#return furthest left
	
		#get furthest right alien
	#calculate offset needed to push him over the edge
	#if over the enge then add 1 to row offset $a1
	#so it would be ((furthest alien index + 1) * 5 ) would be the last printed area 
	#if that calculation is greater than 80 then add 1 to column and push the row down
	#so that the next iteration will subtract one and print it in the same columns but down a row
	
	#get furthest left alien
	#calculate offset needed to push him over the left edge
	#if offset equals(less than?) negative(closest alien index left)*5)
	#subtract 1 from column and add 1 to row so that it goes over a column past where it should
	#then next iteration moves it back over and it's down a row

	
	
	#add row offset by adding 81 * offset
	#add col offset by multiplying alien by 5
	#adding 4 to the lw to get next part
	#print each next part by adding 81
	#add	$
	#5 is sll 2 + add original value
	#do this for all 3 rows
	
	#for each element in alive rows (top mid bot)
	#if alive print alien on screen
	#if not alive print nothing since we'll be using exact locations

	#when printing bullet check location before putting bullet on screen
	#if bullet location has a value already other than space(or zero or whatever)
	#Find out how to get what alien is at this position
	#if it's the shield character then do delete the bullet
	#!!maybe print bullet first and if alien overwrites bullet then delete it
