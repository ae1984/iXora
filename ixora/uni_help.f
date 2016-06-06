/* uni_help.f
 * MODULE
        HELP
 * DESCRIPTION
        Форма вывода для множественного выбора из справочника
 * RUN
        on help of <var> in frame <frame> do:
          run uni_help ("<codfr>", "<mask>", output <var>).
          displ <var> with frame <frame>. 
        end.
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        16.05.2003 nadejda
 * CHANGES
*/


form 
    t-cods.choice no-label format "x"
    t-cods.code  label "КОД" format "x(10)"
    t-cods.name  label "НАИМЕНОВАНИЕ" format "x(45)"
with 11 down title v-bookname overlay centered row 6 frame uni_book.
