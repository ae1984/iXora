/* 700.i
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
        16/08/06 nataly перевела отчет на histrxbal.
        06/09/06 nataly закомментировала строчку v-bal < 0 then v-bal = 0.
*/

        v-gl = fgl({&gl},trxbal.lev).
        find wgl where wgl.gl eq v-gl no-lock no-error.
        if available wgl then do :
            v-code = string(truncate(v-gl / 100, 0)) + v-r + v-cgr + v-hs.
            if v-code eq ? then
            put stream st-err unformatted 
            v-r eq ? " " v-cgr eq ? " " v-hs eq ? skip
            trxbal.sub " " trxbal.acc " "
            string(v-geoi) " " string(v-cgri) skip
            .
 
            find wt where wt.code eq v-code no-error.
            if not available wt then do:
                create wt.
                wt.code = v-code.
            end.

             find last histrxbal where histrxbal.acc = trxbal.acc and histrxbal.lev = trxbal.lev and 
              histrxbal.subled  = trxbal.subled and histrxbal.crc = trxbal.crc and histrxbal.dt <= v-gldate no-lock no-error.
              if avail histrxbal then v-bal = histrxbal.cam - histrxbal.dam. else v-bal = 0.

              /*  put stream rpt2 skip histrxbal.acc histrxbal.dt histrxbal.lev v-bal.*/
            /* v-bal = trxbal.pcam - trxbal.pdam.*/
            if wgl.type eq "A" or wgl.type eq "E" then 
            v-bal = - v-bal.
          /*   if v-bal < 0 then v-bal = 0.*/
            find last crchis where crchis.crc eq trxbal.crc and 
            crchis.rdt <=  v-gldate no-lock no-error.
/*             displ histrxbal.acc histrxbal.crc  v-bal crchis.rate[1]  .*/
            wt.amt = wt.amt + v-bal * crchis.rate[1] / crchis.rate[9]. 
        end.
