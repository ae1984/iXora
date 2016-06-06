/* acdcvou.f
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

/* acdcvou.f
*/


display
   skip(2)
   space(8)  "DAT. :" vdate skip(2)
   space(8)  "PIE  :" bank.name skip
   space(14) " IMPORTA NODA¶A"  skip(2)
   space(8)  "NO   :" cmp.name  skip
   space(14) " EKSPORTA NODA¶"  skip(2)
   space(8)  "RE   : A/C &  D/C PAZIјM" skip(0)
   space(14) " -----------------" skip(2)
   space(13)
   "MЁS PRIEC…MIES J®№ INFORMЁT KA TURPM…K MINЁTAJS ORDERIS    " skip
   space(8)
   "IR PIEјEMTS UN T… DZЁ№ANA TIKS VEIKTA DATUM… NOR…D§T…..........." skip
   space(8)
   "APAK№…" skip(2)
   space(13) "AKR NR.    : "  rpay.lcno         skip(1)
   space(13) "M®S REF.   : "  rpay.bill    skip(1)
   space(13) "DZE№ANA    : "  rpay.intdue  skip(1)
   space(13) "ORDERA SUM : "  "US$" rpay.drft    skip(1)
   space(13) "SATURS     : "  vtennor        skip(1)
   space(13) "ATL LIKM   : "  rpay.intrate "%" skip(1)
   space(13) "ATL APMAKS : "  "US$" rpay.interest    skip(4)
   space(7)  cond[1]
   " MЁS IERAKST§JAM DEBET… NO IEK№ KONTA ATLAIDES SUMMU №ODIEN"
   skip
   space(14)  "UN IERAKST§SIM DEBET… ORDERA SUMMU DZE№.DAT." skip(2)

   space(7) cond[2]
   " ATLAIDES SUMMA KOP… AR ORDERA SUMMU TIKS IERAKST§T… DEBET…  " skip
   space(14) "NO IEK№ЁJA KONTA DZE№ANAS DATUM… ." SKIP(2)
   SPACE(14) " ** J… B®S K…DAS AT№ґIR§BAS APRЁґINOS / TERMIјOS,L®DZU " SKIP
   SPACE(14) " KONTAKT AR MUMS STEIDZ" SKIP(4)
   space(55) ofc.name format "x(25)" skip
   space(53) fill("-",27) format "x(27)" at 54 skip
   space(55) vcmp skip
   with no-box no-label.
