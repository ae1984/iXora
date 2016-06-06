﻿ /* r-riskline_wrk.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Расчет операционного риска по направлениям деятельности
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
        02.04.2013 dmitriy. ТЗ 1690
 * BASES
        BANK COMM
 * CHANGES
        04.04.2013 dmitriy - убрал лишний /
*/

/*-------------------- WRK1 ----------------------------------------*/
create wrk1.    wrk1.nom = 1.   wrk1.beta = 18.   wrk1.name = "Корпоративные финансы (банковское обслуживание юридических лиц)".
create wrk1.    wrk1.nom = 2.   wrk1.beta = 12.   wrk1.name = "Розничные операции (банковское обслуживание физических лиц)".
create wrk1.    wrk1.nom = 3.   wrk1.beta = 18.   wrk1.name = "Платежи и расчеты (Осуществление платежей и расчетов, кроме платежей и расчетов, осуществляемых в рамках обслуживания своих клиентов)".
create wrk1.    wrk1.nom = 4.   wrk1.beta = 18.   wrk1.name = "Торговая деятельность (Операции и сделки на рынке ценных бумаг и срочных финансовых инструментов)".
create wrk1.    wrk1.nom = 5.   wrk1.beta = 15.   wrk1.name = "Агентские услуги".
create wrk1.    wrk1.nom = 6.   wrk1.beta = 15.   wrk1.name = "Коммерческое банковские обслуживание (Оказание банковских услуг корпоративным клиентам, органам государственной власти и местного самоуправления на рынке ".
create wrk1.    wrk1.nom = 7.   wrk1.beta = 12.   wrk1.name = "Брокерская деятельность".
create wrk1.    wrk1.nom = 8.   wrk1.beta = 12.   wrk1.name = "Управление активами".
create wrk1.    wrk1.nom = 9.   wrk1.beta = 12.   wrk1.name = "Иное".


/*-------------------- WRK2 ----------------------------------------*/

create wrk2.
wrk2.id = 1.    wrk2.nom = 1.   wrk2.name = "Предоставление кредитов (займов) и привлечение депозитов;".
wrk2.inc-gl = "4301,4302,4303,4304,4305,4306,4309,4310,4311,4312,4321,4322,4323,4324,4325,4326,4327,4328,4330,4331,4401,4403,4411,4417,4424,4426,4427,4428,4429,4430,4431,4432,4433,4434,4440,4705,4707,4491,4492,4618,4952,4955,4956,4958,4101,4102,4103,4104,4105,4251,4252,4253,4254,4255,4256,4257,4260,4261,4262,4263,4264,4265,4266,4270,4951".
wrk2.exp-gl = "5203,5211,5212,5215,5216,5217,5219,5221,5223,5224,5225,5226,5228,5229,5230,5232,5233,5234,5236,5240,5452,5455,5466,5705,5708,5309,5465,5468,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5133,5134,5135,5136,5137,5138,5140,5141,5451".

create wrk2.
wrk2.id = 2.    wrk2.nom = 1.   wrk2.name = "открытие и ведение банковских счетов юридических лиц, осуществление платежей по поручению юридических лиц;".
wrk2.inc-gl = "4601,4607,4610".
wrk2.exp-gl = "5601,5607".

create wrk2.
wrk2.id = 3.    wrk2.nom = 1.   wrk2.name = "операции с векселями;".
wrk2.inc-gl = "4405".
wrk2.exp-gl = "5235".

create wrk2.
wrk2.id = 4.    wrk2.nom = 1.   wrk2.name = "выдача банковских гарантий и поручительств;".
wrk2.inc-gl = "4606,4612".
wrk2.exp-gl = "5606,5925".

create wrk2.
wrk2.id = 5.    wrk2.nom = 1.   wrk2.name = "факторинговые, форфейтинговые операции;".
wrk2.inc-gl = "4407,4422,4613,4614".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 6.    wrk2.nom = 1.   wrk2.name = "лизинговые операции;".
wrk2.inc-gl = "4420".
wrk2.exp-gl = "5227".

create wrk2.
wrk2.id = 7.    wrk2.nom = 1.   wrk2.name = "кассовое обслуживание, инкассация;".
wrk2.inc-gl = "4611,4615".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 8.    wrk2.nom = 1.   wrk2.name = "оказание консультационных, информационных услуг;".
wrk2.inc-gl = "4921".
wrk2.exp-gl = "5921".

create wrk2.
wrk2.id = 9.    wrk2.nom = 1.   wrk2.name = "предоставление других услуг".
wrk2.inc-gl = "4900,4953,4957,4959,4608,4922".
wrk2.exp-gl = "5900,5453,5457,5459,5608,5922,5924".

create wrk2.
wrk2.id = 10.    wrk2.nom = 2.   wrk2.name = "Предоставление кредитов (займов) и привлечение денежных средств во вклады;".
wrk2.inc-gl = "4301,4302,4303,4304,4305,4306,4309,4310,4311,4312,4321,4322,4323,4324,4325,4326,4327,4328,4330,4331,4401,4403,4411,4417,4424,4426,4427,4428,4429,4430,4431,4432,4433,4434,4440,4705,4707,4491,4492,4618,4952,4955,4956,4958,4101,4102,4103,4104,4105,4251,4252,4253,4254,4255,4256,4257,4260,4261,4262,4263,4264,4265,4266,4270,4951".
wrk2.exp-gl = "5203,5211,5212,5215,5216,5217,5219,5221,5223,5224,5225,5226,5228,5229,5230,5232,5233,5234,5236,5240,5452,5455,5466,5705,5708,5309,5465,5468,5121,5122,5123,5124,5125,5126,5127,5128,5129,5130,5133,5134,5135,5136,5137,5138,5140,5141,5451".

create wrk2.
wrk2.id = 11.    wrk2.nom = 2.   wrk2.name = "открытие и ведение банковских счетов физических лиц, осуществление платежей по поручению физических лиц;".
wrk2.inc-gl = "4601,4607,4610".
wrk2.exp-gl = "5601,5607".

create wrk2.
wrk2.id = 12.    wrk2.nom = 2.   wrk2.name = "доверительное управление денежными средствами и (или) ценными бумагами;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 13.    wrk2.nom = 2.   wrk2.name = "предоставление консультаций по вопросам инвестирования;".
wrk2.inc-gl = "4921".
wrk2.exp-gl = "5921".

create wrk2.
wrk2.id = 14.    wrk2.nom = 2.   wrk2.name = "обслуживание банковских карт, кассовое обслуживание;".
wrk2.inc-gl = "4611,4615".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 15.    wrk2.nom = 2.   wrk2.name = "предоставление других услуг".
wrk2.inc-gl = "4900,4953,4957,4959,4608".
wrk2.exp-gl = "5900,5453,5457,5459,5608,5922,5924".

create wrk2.
wrk2.id = 16.    wrk2.nom = 3.   wrk2.name = "Осуществление расчетов на нетто-основе, клиринг;".
wrk2.inc-gl = "4051,4052".
wrk2.exp-gl = "5021,5022,5023,5024,5026".

create wrk2.
wrk2.id = 17.    wrk2.nom = 3.   wrk2.name = "осуществление валовых расчетов;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 18.    wrk2.nom = 3.   wrk2.name = "инкассовые операции".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 19.    wrk2.nom = 4.   wrk2.name = "Приобретение ценных бумаг с целью получения инвестиционного дохода или с целью получения дохода от их реализации (перепродажи);".
wrk2.inc-gl = "4201,4202,4452,4453,4454,4455,4481,4482,4510,4592,4603,4709,4710,4733,4734,4954".
wrk2.exp-gl = "5301,5303,5305,5306,5307,5308,5464,5510,5592,5603,5709,5710,5733,5734".

create wrk2.
wrk2.id = 20.    wrk2.nom = 4.   wrk2.name = "срочные сделки с ценными бумагами, иностранной валютой, драгоценными металлами, деривативами;".
wrk2.inc-gl = "4604,4616,4703,4704,4530,4540,4731,4732,4891,4892,4893,4895,4896,4897".
wrk2.exp-gl = "5703,5704,5530,5540,5731,5732,5891,5892,5893,5895,5896,5897,5604".

create wrk2.
wrk2.id = 21.    wrk2.nom = 4.   wrk2.name = "выполнение функций маркет-мейкера;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 22.    wrk2.nom = 4.   wrk2.name = "позиции, открываемые за счет собственных средств;".
wrk2.inc-gl = "4471,4472,4475,4476,4713,4851,4856,4871,4872,4923".
wrk2.exp-gl = "5713,5851,5856,5871,5872".

create wrk2.
wrk2.id = 23.    wrk2.nom = 4.   wrk2.name = "операции РЕПО;".
wrk2.inc-gl = "4465".
wrk2.exp-gl = "5250".

create wrk2.
wrk2.id = 24.    wrk2.nom = 4.   wrk2.name = "другие операции".
wrk2.inc-gl = "4560,4570,4580,4590,4591,4593,4594".
wrk2.exp-gl = "5560,5570,5580,5590,5591,5593,5594".

create wrk2.
wrk2.id = 25.    wrk2.nom = 5.   wrk2.name = "Доверительное хранение документов, ценных бумаг, депозитарных расписок, денежных средств и иного имущества, ведение ""эскроу"" (""escrow"") счетов;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 26.    wrk2.nom = 5.   wrk2.name = "осуществление агентских функций для эмитентов и функций платежного агента".
wrk2.inc-gl = "4602,4617".
wrk2.exp-gl = "5602".

create wrk2.
wrk2.id = 27.    wrk2.nom = 6.   wrk2.name = "Первичное размещение эмиссионных ценных бумаг (в том числе гарантированное размещение ценных бумаг);".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 28.    wrk2.nom = 6.   wrk2.name = "оказание банковских услуг при слиянии, поглощении или приватизации юридических лиц;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 29.    wrk2.nom = 6.   wrk2.name = "секьюритизация;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 30.    wrk2.nom = 6.   wrk2.name = "исследования рынков;".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 31.    wrk2.nom = 6.   wrk2.name = "инвестиционный консалтинг".
wrk2.inc-gl = "".
wrk2.exp-gl = "".

create wrk2.
wrk2.id = 32.    wrk2.nom = 7.   wrk2.name = "Различные брокерские услуги (в том числе розничные)".
wrk2.inc-gl = "4609".
wrk2.exp-gl = "5609".

create wrk2.
wrk2.id = 33.    wrk2.nom = 8.   wrk2.name = "Доверительное управление фондами (ценные бумаги, денежные средства и другое имущество, переданное в доверительное управление разными лицами и объединенное на праве общей собственности, а также приобретенное в рамках договора доверительного управления)".
wrk2.inc-gl = "4445,4605".
wrk2.exp-gl = "5204,5605".

create wrk2.
wrk2.id = 34.    wrk2.nom = 9.   wrk2.name = "Все, что не вошло в направления 1-8".
wrk2.inc-gl = "".
wrk2.exp-gl = "".
