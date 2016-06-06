/* r-padi.p
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
        17.03.2004 nataly добавлена обработка счета в ЕВРО по внебалансу
        15.08.2006 u00600 оптимизация
*/

/* r-padi.p  by Kanat 
   остатки на счетах ARP за период по счетам 187010 ГК и 76106 ARP*/

/* 23/06/03 nataly была добавлена сортировка по валютам внутри ГК */

/* Прописываются глобальные переменные */
{mainhead.i ARPBAL}

/*Прописываются переменные*/
def var v-bal as dec format "zz,zzz,zzz,zzz.99-".
define variable v-balrate as dec format "zz,zzz,zzz,zzz.99-".
def var v-asof as date label "DATE".

def var  v-gl like gl.gl.
def var v-des like gl.des.
def buffer bgl for gl.

def buffer bjl for jl.
def var v-kom as decimal.
/* конечная дата */
def var v-asot as date label "DATE".

/* Итоговые суммы по сч.ГК или счетам 000076106 */
def var sum-gl as dec format "zz,zzz,zzz,zzz.99-".

/* Итоговые суммы по всем счетам ARP */
def var final-sumbal as dec format "zz,zzz,zzz,zzz.99-" extent 11.

def var s-jh as integer.

v-asof = g-today.
v-asot = g-today.

/* Указываем что создаем img файл для отчета и спрашиваем у пользователя Append или Overwrite */
{image1.i rpt.img}

/*Форма для опроса пользователя номера счета (v-arp), конечной даты (v-asof), начальной даты (v-asot)*/
/*{a-arp.f}*/

form v-asof  label "НАЧАЛЬНАЯ ДАТА  "
     v-asot  label "КОНЕЧНАЯ ДАТА  "	
     with frame opt.

/*Если отчет запускается спрашиваем у пользователя номер счета и дату отчета*/
if g-batch eq false then
    update v-asof v-asot with row 8 centered no-box side-label frame opt.

/*Процедура которая вызывается всякий раз когда есть возможность в программе дать какой - либо выбор пользователю*/
{image2.i}

/*Вызывается перед циклом чтения данных - ей передается количество печатываемых строк в отчете, вызывается output*/
{report1.i 63}

/* Соединяем ARP таблицу со счетами 000187010 и 000076106 , 000076643*/

    for each arp no-lock where arp.gl = 187010 or arp.arp = "000076106" or  arp.arp = "000076643" 
    break by arp.gl by arp.crc:
    vtitle = "ARP остатки за период". 

    /*задаем параметры шапки отчета и устанавливаем его ширину - 88 символов*/
    {report2.i 88}  

/* Соединяем главную книгу с ARP */
   if arp.arp <> '000076106' and arp.arp <> '000076643' then 
    find gl where gl.gl eq arp.gl no-lock.
   else do:
     find trxlevgl where trxlevgl.gl = arp.gl and trxlevgl.subled = 'arp'
        and trxlevgl.lev = 7 no-lock no-error.
     if available trxlevgl then  do: 
      find bgl where bgl.gl = trxlevgl.glr no-lock no-error.
      v-gl = bgl.gl. v-des = bgl.des. end.
   end.

       if first-of(arp.gl)  then do:
       case arp.gl:
        when 187010 then do: 
            display gl.gl gl.des v-asof v-asot with side-label frame gl1.
            put fill("-",88) format "x(88)" skip.
            put "КАРТ.Nr."
            "ДАТА ПРОВОДКИ " 
            "ТИП "
            " РИСК"
            "       ОПИСАНИЕ "
            "              ГЕО" 
            " ВАЛ"
            "            НОМИНАЛ " skip.
            put fill("-",88) format "x(88)" skip. end.
        otherwise do: 
            display v-gl v-des v-asof v-asot with side-label frame gl2.
            put fill("-",88) format "x(88)" skip.
            put "КАРТ.Nr."
            "ДАТА ПРОВОДКИ " 
            "ТИП "
            " РИСК"
            "       ОПИСАНИЕ "
            "              ГЕО" 
            " ВАЛ"
            "            НОМИНАЛ " skip.
            put fill("-",88) format "x(88)" skip. end.
        end case.

        end. /*if first-of*/
     

    for each jl no-lock where jl.acc eq arp.arp and jl.dc = 'd' and 
             jl.jdt ge v-asof and jl.jdt le v-asot and 
             (jl.gl = 187010 or jl.gl = v-gl)           

          use-index jl-idx1:  

    if s-jh <> jl.jh then  do:
    /* учитываем комиссию за транзакцию */
    find bjl where bjl.jh = jl.jh and bjl.dc = 'd' 
        and bjl.ln <> jl.ln and bjl.acc = jl.acc no-lock no-error.
    if available bjl then v-kom = bjl.dam. 
      else v-kom = 0.
    put
         jl.jh "  " 
        arp.arp " "
        jl.jdt  format "99/99/9999" " "
        " "
        arp.type  format "999" " "
        arp.risk format "zz9" " "
       ( if arp.gl = 187010 then arp.des else jl.rem[2]) format 'x(30)' " "
        arp.geo  format "x(3)"
        " " arp.crc " "
        jl.dam + v-kom  
        format "zz,zzz,zzz.99" at 80 " " skip.

      s-jh = jl.jh.
      sum-gl = sum-gl + jl.dam + v-kom.
      final-sumbal[arp.crc] = final-sumbal[arp.crc] + jl.dam + v-kom.
     end.
    end.

    if last-of(arp.crc) and sum-gl <> 0  then do:
       find crc where crc.crc = arp.crc no-lock no-error.
        put 
        "Итого по счету ГК "  at 41  arp.gl " в валюте " crc.code format 'x(3)'
        sum-gl  format "zz,zzz,zzz.99" at 80 skip(1).
        sum-gl = 0. 
    end.


end.

def var i as integer.
/* Вывод итоговой суммы по всем счетам ARP */
do i = 1 to 11:
find crc where crc.crc = i no-lock no-error.
     if final-sumbal[i] <> 0 then
/*        put  fill(" ",50) format "x(50)"*/
  put    "ИТОГО ПО ВСЕМ СЧЕТАМ ARP В ВАЛЮТЕ  "  at 41 crc.code format 'x(3)'
        final-sumbal[i] format "zz,zzz,zzz.99"  at 80.
end.

{report3.i}
{image3.i}
