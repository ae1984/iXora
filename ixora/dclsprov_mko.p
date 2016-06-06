/* dclsprov_mko.p
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
	    Начисление, списание провизий в МКО
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
        01/10/2011 madiyar - вернул ревизию 1.4 для базы МКО
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def new shared var s-jh like jh.jh.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var vdel as char no-undo initial "^".

def var bilance as deci no-undo.
def var prc as deci no-undo.
def var pen as deci no-undo.

def var v-provprc as deci no-undo.

def var v-prov_cur_od as deci no-undo.
def var v-prov_sh_od as deci no-undo.
def var v-prov_cur_prc as deci no-undo.
def var v-prov_sh_prc as deci no-undo.
def var v-prov_cur_pen as deci no-undo.
def var v-prov_sh_pen as deci no-undo.

def var v-bal as deci no-undo.
def var v-sum as deci no-undo.

def var v-tmpl as char no-undo.
def var v-rem as char no-undo.
def var v-knp as char no-undo init "490".


def temp-table t-lonres no-undo
  field jdt as date
  field jh as integer
  field dc as char
  field amt as deci
  index idx is primary jdt jh.

def stream rep.
output stream rep to value("lonprov" + string(year(g-today)) + string(month(g-today),"99") + ".txt").

put stream rep unformatted "          Клиент Сс.счет                 Было            Создано            Списано              Стало Trx#" skip
                           "          ------ --------- ------------------ ------------------ ------------------ ------------------ ----------" skip.

for each lon no-lock:

    if lon.opnamt <= 0 then next.

    /* 31.07.06 marinav - если есть такой признак, то создавать провизии не надо */
    find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnprov' and sub-cod.ccode = '1' no-lock no-error.
    if avail sub-cod then next.

    /*
    bilance = levbal('lon',lon.lon,"1,7",lon.crc,1).
    v-prov_cur = levbal('lon',lon.lon,"6",1,-1).
    */

    run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output bilance).
    run lonbalcrc('lon',lon.lon,g-today,"2,9",yes,lon.crc,output prc).
    run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output pen).
    run lonbalcrc('lon',lon.lon,g-today,"6",yes,lon.crc,output v-prov_cur_od).
    v-prov_cur_od = - v-prov_cur_od.
    run lonbalcrc('lon',lon.lon,g-today,"36",yes,lon.crc,output v-prov_cur_prc).
    v-prov_cur_prc = - v-prov_cur_prc.
    run lonbalcrc('lon',lon.lon,g-today,"37",yes,1,output v-prov_cur_pen).
    v-prov_cur_pen = - v-prov_cur_pen.

    v-sum = 0.

    if bilance <= 0 and prc <= 0 and pen < 0 and v-prov_cur_od <= 0 and v-prov_cur_prc <= 0 and v-prov_cur_pen <= 0 then next.

    find last lonhar where lonhar.lon = lon.lon use-index lonhar-idx1 no-lock no-error.
    if not avail lonhar then next.

    find first lonstat where lonstat.lonstat = lonhar.lonstat no-lock no-error.
    if not avail lonstat then next.

    v-provprc = lonstat.prc.

    v-prov_sh_od = round(bilance * v-provprc / 100, 2).
    v-prov_sh_prc = round(prc * v-provprc / 100, 2).
    v-prov_sh_pen = round(pen * v-provprc / 100, 2).

    if (v-prov_sh_od = v-prov_cur_od) and (v-prov_sh_prc = v-prov_cur_prc) and (v-prov_sh_pen = v-prov_cur_pen) then next.

    if (v-prov_sh_od <> v-prov_cur_od) then do:
        if v-prov_cur_od > v-prov_sh_od then do transaction:

            v-sum = v-prov_cur_od - v-prov_sh_od.

            v-rem = "Списание спец. накоплений по ОД, сс.счет " + lon.lon.
            v-tmpl = "lon0022".

            vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel +
                     v-knp.

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Списание по ОД " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).

            put stream rep unformatted
                "СписОД    " lon.cif " " lon.lon " "
                v-prov_cur_od format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_od format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end. /* if v-prov_cur > v-prov_sh */
        else do transaction:

            v-rem = "Создание спец. накоплений по ОД, сс.счет " + lon.lon.
            v-tmpl = "lon0020".
            v-sum = v-prov_sh_od - v-prov_cur_od.
            vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel +
                     v-knp.

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Создание по ОД " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).
            put stream rep unformatted
                "СозданОД  " lon.cif " " lon.lon " "
                v-prov_cur_od format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_od format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end.
    end.

    if (v-prov_sh_prc <> v-prov_cur_prc) then do:
        if v-prov_cur_prc > v-prov_sh_prc then do transaction:

            v-sum = v-prov_cur_prc - v-prov_sh_prc.

            v-rem = "Списание спец. накоплений по %%, сс.счет " + lon.lon.
            v-tmpl = "lon0144".

            vparam = string(v-sum) + vdel + string(lon.crc) + vdel + '36' + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "".

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Списание по %% " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).

            put stream rep unformatted
                "Спис%%    " lon.cif " " lon.lon " "
                v-prov_cur_prc format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_prc format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end.
        else do transaction:

            v-rem = "Создание спец. накоплений по %%, сс.счет " + lon.lon.
            v-tmpl = "lon0143".
            v-sum = v-prov_sh_prc - v-prov_cur_prc.
            vparam = string(v-sum) + vdel + string(lon.crc) + vdel + '36' + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "".

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Создание по %% " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).
            put stream rep unformatted
                "Создан%%  " lon.cif " " lon.lon " "
                v-prov_cur_prc format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_prc format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end.
    end.

    if (v-prov_sh_pen <> v-prov_cur_pen) then do:
        if v-prov_cur_pen > v-prov_sh_pen then do transaction:

            v-sum = v-prov_cur_pen - v-prov_sh_pen.

            v-rem = "Списание спец. накоплений по штрафам, сс.счет " + lon.lon.
            v-tmpl = "lon0144".

            vparam = string(v-sum) + vdel + '1' + vdel + '37' + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "".

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Списание по штрафам " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).

            put stream rep unformatted
                "СписШтр   " lon.cif " " lon.lon " "
                v-prov_cur_pen format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_pen format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end.
        else do transaction:

            v-rem = "Создание спец. накоплений по штрафам, сс.счет " + lon.lon.
            v-tmpl = "lon0143".
            v-sum = v-prov_sh_pen - v-prov_cur_pen.
            vparam = string(v-sum) + vdel + '1' + vdel + '37' + vdel +
                     lon.lon + vdel +
                     v-rem + vdel + "" + vdel + "" + vdel + "" + vdel + "".

            s-jh = 0.
            run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

            if rcode <> 0 then do:
                put stream rep unformatted "Создание по штрафам " lon.cif " " lon.lon " Ошибка! " rdes skip.
                message rcode rdes.
                pause.
                undo, next.
            end.

            run lonresadd(s-jh).
            put stream rep unformatted
                "СозданШтр " lon.cif " " lon.lon " "
                v-prov_cur_pen format ">>>,>>>,>>>,>>9.99" " "
                v-sum format ">>>,>>>,>>>,>>9.99" " "
                0 format ">>>,>>>,>>>,>>9.99" " "
                v-prov_sh_pen format ">>>,>>>,>>>,>>9.99" " "
                s-jh skip.

        end.
    end.

end.

output stream rep close.
