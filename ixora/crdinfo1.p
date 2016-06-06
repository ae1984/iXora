/* crdinfo1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        26/01/2011 id00004
 * BASES
        BANK COMM TXB
 * CHANGES
        31/01/2011 id00004 изменил значение в формуле 
        30.11.2011 id00004 убрал ГК 145... из расчета согласно ТЗ
*/


  def shared var sum as decimal.
  def shared var v-tday as date.
  def var glval as decimal.


function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for txb.crchis.
define buffer bcrc2 for txb.crchis.



if d1 = 10.01.08 or d1 = 12.01.08 then do:
    if c1 <> c2 then 
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    

end.
do:
    if c1 <> c2 then 
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    
end.


end.


function getGL returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:
            res1 = txb.glday.dam - txb.glday.cam.
            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
/*                    res = res + round(crc-crc-date(decimal(res1), txb.crc.crc, 2, p-dt - 1),2). */
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1]. 
                end.
            end.
        end.
    end.
    return res.
end function.

function str2GL returns integer (input p-glstr as char, input p-gltype as char).
    def var res as integer no-undo.
    res = 0.
    def var v-i as integer no-undo.
    v-i = ?.
    def var v-c as char no-undo.
    v-c = ''.
    p-glstr = trim(p-glstr).
    if (p-gltype = "start") or (p-gltype = "end") then do:
        if p-gltype = "start" then v-c = '0'. else v-c = '9'.
        if (p-glstr <> '') and length(p-glstr) <= 6 then do:
            v-i = integer(p-glstr) no-error.
            if (v-i <> ?) and (v-i > 0) then do:
                res = integer(p-glstr + fill(v-c,6 - length(p-glstr))).
            end.
        end.
    end.
    return res.
end function.

function getGroupGL returns deci (input p-gr as char, input p-ex as char, input p-dt as date).
    def var res as deci no-undo.
    def var v-i as integer no-undo.
    def var v-j as integer no-undo.
    def var gr as char no-undo.
    p-gr = trim(p-gr).
    p-ex = trim(p-ex).
    res = 0.
    if p-gr <> '' then do:
        do v-i = 1 to num-entries(p-gr):
            gr = entry(v-i,p-gr).
         g: for each txb.gl where txb.gl.gl >= str2GL(gr,"start") and txb.gl.gl <= str2GL(gr,"end") no-lock:
                /* gl.totact = no gl.totlev = 1 */
                if gl.totact then next.
                if p-ex <> '' then do:
                    do v-j = 1 to num-entries(p-ex):
                        if substring(string(txb.gl.gl),1,length(entry(v-j,p-ex))) = entry(v-j,p-ex) then next g.
                    end.
                end.
                res = res + getGL(txb.gl.gl,p-dt).
            end.
        end. /* do v-i */
    end. /* if p-gr <> '' */
    return res.
end function.




  glval = 0.
/*  glval = abs(getGroupGL("14",'',v-tday - 1)) - abs(getGroupGL("32",'',v-tday - 1)). */
  glval = abs(getGroupGL("14",'',v-tday - 1)) - abs(getGroupGL("32",'',v-tday - 1))  - abs(getGroupGL("145",'',v-tday - 1)).  

  sum = sum + glval.










