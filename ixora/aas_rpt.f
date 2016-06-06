/* aas_rpt.f
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

/*
 aas_rpt.f
*/


FORM
   dSakDat AT 10 SKIP (1)
   dBeiDat AT 10 SKIP (1)
   s-aaa VALIDATE(s-aaa= "" OR can-find(aaa WHERE s-aaa= aaa.aaa
      USE-INDEX aaa), "Счет не найден !") AT 10 SKIP (1)
   s-ofc VALIDATE(s-ofc= "" OR can-find(ofc WHERE s-ofc= ofc.ofc
      USE-INDEX ofc), "Исполнитель не найден !") AT 10 SKIP (1)
   s-sic VALIDATE(s-sic= "" OR can-find(sic WHERE s-sic= sic.sic
      USE-INDEX sic), "Спец.инстр. не найдена !") AT 10
   WITH COLUMN 10 ROW 5 50 COLUMNS WIDTH 50 SIDE-LABEL FRAME aas_parm.
