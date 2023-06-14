EXEC = edit

FOENIX = module/Calypsi-m68k-Foenix

BUILD_VER = 1.0.1 RK $(shell date +"%b %d %Y %H:%M")

# Common source files
ASM_SRCS =
C_SRCS = edit.c input.c
 
MODEL = --code-model=large --data-model=large
LIB_MODEL = lc-ld
C_FLAGS = -Iinclude -DA2560=1 -DUSE_DL=0 -DNO_WCHAR=1 -DBUILD_VER="\"$(BUILD_VER)\""

A2560K_RULES = a2560k.scm

# Object files
OBJS = $(ASM_SRCS:%.s=obj/%.o) $(C_SRCS:%.c=obj/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=obj/%-debug.o) $(C_SRCS:%.c=obj/%-debug.o)

all: $(EXEC).pgz

obj/%.o: %.s
	as68k --core=68000 $(MODEL) --target=Foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%.o: %.c
	cc68k $(C_FLAGS) --core=68000 $(MODEL) --target=Foenix --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.s
	as68k --core=68000 $(MODEL) --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.c
	cc68k $(C_FLAGS) --core=68000 $(MODEL) --target=Foenix --debug --list-file=$(@:%.o=%.lst) -o $@ $<

$(EXEC).pgz:  $(OBJS)
	ln68k -o $@ $^ $(A2560K_RULES) --output-format=pgz --list-file=$(EXEC).lst --rtattr printf=float --rtattr scanf=float --rtattr cstartup=Foenix_user --stack-size=65536 --heap-size=262144

$(EXEC).hex:  $(OBJS_DEBUG)
	ln68k -o $@ $^ $(A2560K_RULES) --output-format=intel-hex --list-file=$(EXEC).lst --rtattr printf=float --rtattr scanf=float --rtattr cstartup=Foenix_user --stack-size=65536 --heap-size=262144

clean:
	-rm $(OBJS) $(OBJS:%.o=%.lst) $(OBJS_DEBUG) $(OBJS_DEBUG:%.o=%.lst)
	-rm $(EXEC).pgz $(EXEC).elf $(EXEC).lst 
