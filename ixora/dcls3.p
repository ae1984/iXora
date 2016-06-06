/* dcls3.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        09.22.1990 created by Simon Y. Kim
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов
        12.01.2006 u00121 - добавил avail для t-glbal, а то некоторые лица забыли как-то завести счет ГК, который был итоговым для некторых др.счетов... вообщем теперь при закрытии дня ругается культурно...
        14.05.2012 madiyar - glbal при отсутствии просто молча создается
*/

{global.i}
define buffer b-gl for gl.
define buffer b-glbal for glbal.
define buffer t-glbal for glbal.
define buffer netpr for sysc.
define buffer netpri for sysc.
define buffer netls for sysc.
define buffer netlsi for sysc.
define var vnet like jl.dam.
define var inc  like gl.totlev.
define var vasof as date.
define var vbal like jl.dam label "B A L A N C E  ".
define var vod like glbal.bal.
define var vcrc as int.
find netpr  where netpr.sysc  eq "NETPR".
find netpri where netpri.sysc eq "NETPRI".
find netls  where netls.sysc  eq "NETLS"  no-error.
find netlsi where netlsi.sysc eq "NETLSI" no-error.

for each glbal:
    glbal.bal = 0.
end.

for each crc where crc.sts <> 9 no-lock:
    vcrc = crc.crc.
    vnet = 0.

    c-gl:
    for each gl no-lock where gl.totact = false use-index totact:
        if lookup(gl.type, "E,R") = 0 then next c-gl.
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
        vnet = vnet + glbal.cam - glbal.dam.
    end.

    if vnet >= 0 or netls.inval = 0 then do:
        find gl where gl.gl = netpr.inval.
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
        glbal.bal = vnet.
        find gl where gl.gl = netpri.inval.
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
        glbal.bal = vnet.
    end.
    else do:
        find gl where gl.gl eq netls.inval.
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
        glbal.bal = - vnet.
        find gl where gl.gl = netlsi.inval.
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
        glbal.bal = - vnet.
    end.

    for each gl no-lock where gl.totact = false use-index totact:
        find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.

        if gl.revgl = 0 then do:
            glbal.bal = glbal.dam - glbal.cam.
            if gl.type = "L" or gl.type = "O" or gl.type = "R" then glbal.bal = - glbal.bal.
        end.  /* if gl.revgl = 0 */
        else if gl.sts = 0 then do:
            if gl.subled = "dfb" then do:
                vod = 0.
                for each dfb where dfb.gl = gl.gl and dfb.crc = vcrc:
                    if dfb.dam[1] - dfb.cam[1] < 0 then vod = vod + dfb.dam[1] - dfb.cam[1].
                    else glbal.bal = glbal.bal + dfb.dam[1] - dfb.cam[1].
                end. /* for each dfb */

                find b-gl where b-gl.gl = gl.revgl.
                find b-glbal where b-glbal.gl = gl.revgl and b-glbal.crc = crc.crc.
                b-glbal.bal = vod.
                if gl.type = "L" or gl.type = "O" or gl.type = "R" then glbal.bal = - glbal.bal.
                if b-gl.type = "L" or b-gl.type = "O" or b-gl.type = "R" then b-glbal.bal = - b-glbal.bal.
            end. /* if gl.subled = "dfb" */
            else if gl.subled = "iof" then do:
                vod = 0.
                for each iof where iof.gl = gl.gl and iof.crc = vcrc:
                    if iof.dam[1] - iof.cam[1] < 0 then vod = vod + iof.dam[1] - iof.cam[1].
                    else glbal.bal = glbal.bal + iof.dam[1] - iof.cam[1].
                end. /* for each iof */
                find b-gl where b-gl.gl = gl.revgl.
                find b-glbal where b-glbal.gl = gl.revgl and b-glbal.crc = crc.crc.
                b-glbal.bal = vod.
                if gl.type = "L" or gl.type = "O" or gl.type = "R" then glbal.bal = - glbal.bal.
                if b-gl.type = "L" or b-gl.type = "O" or b-gl.type = "R" then b-glbal.bal = - b-glbal.bal.
            end. /* else if gl.subled = "iof" */
            else do:
                glbal.bal = glbal.dam - glbal.cam.
                if gl.type = "L" or gl.type = "O" or gl.type = "R" then glbal.bal = - glbal.bal.
                if glbal.bal < 0 then do:
                    find b-gl where b-gl.gl = gl.revgl.
                    find b-glbal where b-glbal.gl = gl.revgl and b-glbal.crc = crc.crc.
                    b-glbal.bal = - glbal.bal.
                    glbal.bal = 0.
                end.
            end. /* else do */
        end. /* else if gl.sts = 0 */
    end.  /* for each gl */

    repeat inc = 1 to 9:
        for each gl where gl.totlev = inc and gl.totgl > 0 use-index totlevgl:
            find glbal where glbal.gl = gl.gl and glbal.crc = crc.crc.
            find last t-glbal where t-glbal.gl = gl.totgl and t-glbal.crc = crc.crc no-error.
            if not avail t-glbal then do:
                create t-glbal.
                t-glbal.gl = gl.totgl.
                t-glbal.crc = crc.crc.
            end.
	        t-glbal.bal = t-glbal.bal + glbal.bal.
        end.
    end. /* repeat */

 end. /* vcrc */


 for each glbal:
    find last glday where glday.gl = glbal.gl and glday.crc = glbal.crc no-error.
    if not available glday or (available glday and (glday.dam <> glbal.dam or glday.cam <> glbal.cam or glday.bal <> glbal.bal )) then do:
         create glday.
         assign glday.gl  = glbal.gl
                glday.crc = glbal.crc
                glday.gdt = g-today
                glday.dam = glbal.dam
                glday.cam = glbal.cam
                glday.bal = glbal.bal.
    end.
 end.
