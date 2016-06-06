/* newlon.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* newlon.f
*/

form vvgl colon 20 label " AIZD G/G# " gl.des no-label colon 35 skip
     lon.lon colon 20 label " AIZD# "
     lon.grp colon 47 label " GRP " skip
     lon.cif colon 20 label " KIF# " cif.sname no-label colon 35 skip
     lon.loncat colon 20 label " KATEGOR. "
     loncat.des no-label colon 35 skip
     lon.opnamt colon 20 label " SUMMA  "
     lon.lcr colon 47 label " AKR# "  skip
     lon.rdt colon 20 label " REG-DAT. "    " --- " at 32
	lon.duedt  colon 47 label " MKS-DAT."
	validate(lon.duedt gt lon.rdt,"K¶®D. IEVЁ№AN")
     vterm colon 67 label " TERM " skip
     lon.base colon 20 label " PRC-LIKM "  lon.prem colon 35 no-label skip
     vvint colon 20 label " PRC-№ODIEN"
     vint colon 53 label " PRC-MЁNBEIG" skip
     lon.ptype colon 20 label " MAKS…JM "
help "1.SKDN  2.OFCL-PRB 3.PNC UZ KONT 4.DFB 5.P…RBD(SKDN-PNT) 6.IOF"
     s-gl colon 20 label " MAKS…JM G/G# "  sgldes colon 35 no-label skip
     s-acc colon 20 label " KONT# "
     lon.cam[3] colon 47 label " PAKALP MAKS " format "$zz,zz9.99" skip
     lon.apr colon 20 label " APSTIPRN "
	lon.gua colon 47 label " NODRO№. " skip
     s-jh  colon 20 label " KONTROL NR. " skip
     with width 80 row 3 side-label centered title " LOAN ISSUE "
     overlay frame lon.
