/* groset.f
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

/* groset.f
*/

form     "SAMAKS№ KONTS   G/G            :"  apagl.inval skip
	 "PAKALP. KOMSNAUDA  G/G         :"  comgl.inval skip(1)
	 "NOR…DES NUMURA KODS            :"  ubpay.code skip
	 "NOR…DES NUMURA APRAKST§№ANA    :"  ubpay.des  skip
	 "NOR…DES  NUMURA FORMATS        :"  ubpay.fmt  skip
	 "NOR…DES   NUMURA PREFIKSS      :"  ubpay.prefix skip
	 "NOR…DES NUMURA SUFIKSS         :"  ubpay.sufix skip
	 "N…K. NUMURS                    :"  ubpay.nmbr
	  with title " PARAMETRU SISTM  " centered
	  row 3 no-label frame setup.
