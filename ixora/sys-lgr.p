/* sys-lgr.p
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

/* sys-lgr.p
*/

{global.i}

{line.i
&var  = "define new shared var s-lgr like lgr.lgr."
&head = "led"
&line = "lgr"
&start = {sys-lgr.f}
&form = "lgr.ln lgr.lgr lgr.des format ""x(30)"" lgr.gl label ""ACCNT"" 
         lgr.accgl lgr.prfgl lgr.nxt label ""NXT"" format ""9"" "
&frame = "row 3 centered overlay 10 down scroll 1
          title "" ACCOUNT GROUP AND NEXT NUMBER """
&flddisp = "lgr.ln lgr.lgr lgr.des lgr.gl lgr.accgl lgr.prfgl lgr.nxt"
&fldupdt = "lgr.lgr lgr.des lgr.gl lgr.accgl lgr.prfgl lgr.nxt"
&posupdt = "
           on help of lgr.autoext in frame xlgr do:
              run uni_help1('spnpl', '3*').
           end.
           on help of lgr.tlev in frame xlgr do:
              run uni_help1('lgrsts', '*').
           end.
           display lgr.lgr lgr.des with frame xlgr.
           update lgr.alt 
                  lgr.avgbal lgr.feemon
                  lgr.chkmon lgr.feechk
                  lgr.feensf lgr.stm
                  lgr.complex lgr.base
                  lgr.lookaaa lgr.crc
                  lgr.pri validate(pri eq ""F"" or
                          can-find(pri where pri.pri eq lgr.pri),"""")
                  lgr.rate
                  lgr.dueday lgr.laterat
                  lgr.intcal lgr.intpay lgr.prd lgr.autoext
                  lgr.tlev    
                  with frame xlgr.
           s-lgr = lgr.lgr.
           run sys-aax.
           "
&index = "ledln"
}


