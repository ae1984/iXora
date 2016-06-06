/* surrend2.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/05/2012 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}

define input parameter v-jh as integer no-undo.
define input parameter v-summ as decimal no-undo.
define input parameter v-arp as character no-undo.
define output parameter v-jh2 as integer no-undo.


def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
def var SP  as class SUPPCOMClass.    /* Класс данных поставщиков */
def new shared var s-jh like jh.jh.   /* Номер проводки */
def var rez as log.                   /* Значение возврата функций*/
def var pos as int init 1.


/***********************************************************************************************************/

      REPEAT on ENDKEY UNDO  , leave :
        CASE pos:

          WHEN 1 THEN
          DO:    /* Выбор из списка поставщиков услуг */
                 Doc = NEW COMPAYDOCClass(Base).
                 Doc:AddData().
                 SP  = NEW SUPPCOMClass(Base).
                 SP:minsum = v-summ.
                 run help-suppay(SP,"no_tax").
                 if SP:supp_id = ? then
                 do:
                    LEAVE.
                 end.
                 else do:
                    Doc:SetSuppData(SP).
                    DELETE OBJECT SP NO-ERROR .
                    pos = 2.
                 end.
          END.
          WHEN 2 THEN
          DO:
                 Doc:summ = v-summ.
                 run compay4(Doc,v-arp,output rez). /*Сдача без комиссии тип провайдера 4*/
                 v-jh2 = Doc:jh.
                 DELETE OBJECT Doc NO-ERROR.

                 if rez then do:
                  find first jh where jh.jh = v-jh2 exclusive-lock no-error.
                  if avail jh then jh.jh2 = v-jh.
                  release jh.
                  LEAVE.
                 end.
                 else do: v-jh2 = 0. pos = 1. end.
          END.
        END CASE.

      END. /*REPEAT*/

/***********************************************************************************************************/

  if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
  if VALID-OBJECT(SP)   then DELETE OBJECT SP  NO-ERROR .

/***********************************************************************************************************/



/*

980944

vparam =         " " + vdel +
       string(Doc:summ) + vdel +
                    "1" + vdel +
                  v-arp + vdel +
                Doc:arp + vdel +
     "Платежи " + Doc:suppname + vdel +
                    "1" + vdel +
                    "1" + vdel +
                    "9" + vdel +
                Doc:knp.
   s-jh = 0.

   run trxgen("JOU0055", vdel, vparam, "ARP", "", output rcode, output rdes, input-output s-jh).

*/





