/* zdfbedit.p
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
        01.11.2004 tsoy добавил статус
*/


def var vans as log init false.
def var cmd as char form "x(13)" extent 5
  initial ["СЛЕДУЮЩИЙ","НАСТРОЙКА","РЕДАКТИРОВАТЬ","УДАЛИТЬ","ВЫХОД"].

def var vyst like jl.dam.
def var vydr like vyst.
def var vycr like vyst.
def var vmst like vyst.
def var vmdr like vyst.
def var vmcr like vyst.
def var vtst like vyst.
def var vtdr like vyst.
def var vtcr like vyst.
def var vyas like vyst.
def var vmas like vyst.
def var vyir like vyst.
def var vyip like vyst.
def var vmir like vyst.
def var vmip like vyst.
def var vbal like vyst.

def var v-subcode as char.
def var v-subname as char.

form cmd with col 63 row 2 no-label frame slct overlay top-only.

{mainhead.i NAENT}  /*  DUE FROM BANK REGISTER  */

loop:
repeat:

  {zdfbedit.f}

  view frame dfb.
  prompt-for dfb.dfb with frame dfb.
  find dfb using dfb.dfb no-error.
  if not available dfb then do:
     bell.
     next .
        end.

     vyst = dfb.ydam[1] - dfb.ycam[1].   /* year start */
     vydr = dfb.dam[1]  - dfb.ydam[1].   /* YTD this year */
     vycr = dfb.cam[1]  - dfb.ycam[1].   /* YTD this year */
     vmst = dfb.mdam[1] - dfb.mcam[1].   /* month start */
     vmdr = dfb.dam[1]  - dfb.mdam[1].   /* MTD this month */
     vmcr = dfb.cam[1]  - dfb.mcam[1].   /* MTD this month */
     vtst = dfb.dam[3]  - dfb.cam[3].    /* yesterday balalce */
     vtdr = dfb.dam[1]  - dfb.dam[3].    /* today Debit */
     vtcr = dfb.cam[1]  - dfb.cam[3].    /* today Credit */
     vbal = dfb.dam[1]  - dfb.cam[1].    /* today balance */
     vyas = dfb.dam[5]  - dfb.ydam[5].   /* This yr accum total */
     vmas = dfb.mdam[5] - dfb.ydam[5].   /* This month accum total */
     vyir = dfb.cam[2]  - dfb.ycam[2].   /* YTD interest rcvd */
     vyip = dfb.dam[2]  - dfb.ydam[2].   /* YTD interest paid */
     vmir = dfb.mcam[2] - dfb.ycam[2] .  /* MTD interest rcvd */
     vmip = dfb.mdam[2] - dfb.ydam[2].   /* MTD interest paid */


     find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-error.

     if avail sub-cod then do:
     
          find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
          v-subcode = sub-cod.ccode.
          v-subname = codfr.name[1].

     end. else do:

           create sub-cod.
                sub-cod.sub   = "dfb".
                sub-cod.acc   = dfb.dfb.
                sub-cod.d-cod = "clsa".
                sub-cod.ccode = "msc".

          find codfr where codfr.codfr = "clsa" and codfr.code = sub-cod.ccode no-lock no-error.
          v-subcode = sub-cod.ccode.
          v-subname = codfr.name[1].

     end.


     display
        dfb.gl
        dfb.crc
        dfb.name
        dfb.addr[1]
        dfb.addr[2]
        dfb.addr[3]
        dfb.tel
        dfb.fax
        dfb.intrate
        dfb.crline
        vtst
        vtdr
        vtcr
        vbal
        v-subcode
        v-subname        
    with frame dfb.


 end.
