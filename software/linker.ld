SECTIONS
{
    RAM_BASE = 0x80200000;

    . = RAM_BASE;
    .text.init : {
	    *(.text.init .text.init.*)
    }
    .text : {
	    *(.text .text.*)
    }
    .data : {
	    *(.data .data.*)
    }
    .sdata : {
	    *(.sdata .sdata.*)
    }
}
