package Lingua::ID::NameParse;
# ABSTRACT: Parse and extract information from Indonesian names

use Any::Moose;

my @salutations = (
    { pat => 'bapak|bpk|bp|tuan|tn'  , sex => 'M' },
    { pat => 'ibu|bu'                , sex => 'F' },
    { pat => 'nyonya|ny'             , sex => 'F', married => 1 },
    { pat => 'nona|nn'               , sex => 'F', married => 0 },
    { pat => 'saudara|sdr'           , sex => 'M' }, # CL = 50%? sdr. lina -> kadang sdr dipakai generik utk co/ce?
    { pat => 'saudari|sdri'          , sex => 'F' },
    { pat => 'haji|h'                , sex => 'M', religion => 'islam' },
    { pat => 'hajj?ah|hj'            , sex => 'F', religion => 'islam' },
    { pat => 'frater|fr'             , sex => 'M', religion => 'catholic' },
    { pat => 'suster|sr'             , sex => 'F', religion => 'catholic' },
    { pat => 'evan[gj]elist?|ev'     , religion => 'christian', professions => ['clergyman'], professions_id => ['penginjil'] },
    { pat => 'reverend|rev'          , religion => 'christian', professions => ['clergyman'], professions_id => ['pendeta'] },
    { pat => 'pendeta|pdt|pend'      , religion => 'christian', professions => ['clergyman'], professions_id => ['pendeta'] },
    { pat => 'past(?:u|oe)r'         , religion => 'christian', professions => ['clergyman'], professions_id => ['pastur'] },

# kakek? nenek? kak/kakak, adik, ...
# bali? bli,...
# padang? uda...
);

# military titles

my @indonesian_prefix_academic_titles = (
    { pat => 'drs'      , level => 'undergraduate', sex => 'M' },
    { pat => 'dra'      , level => 'undergraduate', sex => 'F' },
    { pat => 'drg'      , level => 'undergraduate', professions => ['dentist'], fields => ['medical'] },
    { pat => 'drh'      , level => 'undergraduate', professions => ['veterinarian'], fields => ['medical'] },

    { pat => 'Ir'               , level => 'undergraduate', fields => ['engineering'] },
    { pat => 'do[kc]tor|Dr'     , level => 'postgraduate' , },
    { pat => 'dokter|dr'        , level => 'postgraduate' , professions => ['doctor'], field => 'medical' },
    { pat => 'profess?or|prof'  , },
    );

my @indonesian_suffix_academic_titles = (
    { pat => 'SAg'     , level => 'undergraduate', short_for => 'Sarjana Agama', },
    { pat => 'SArs'    , level => 'undergraduate', short_for => 'Sarjana Arsitektur', },
    { pat => 'SE'      , level => 'undergraduate', short_for => 'Sarjana Ekonomi', },
    { pat => 'SFil'    , level => 'undergraduate', short_for => 'Sarjana Filosofi', },
    { pat => 'SHI'     , level => 'undergraduate', short_for => 'Sarjana Hukum Islam', },
    { pat => 'SH'      , level => 'undergraduate', short_for => 'Sarjana Hukum', fields => ['law'] },
    { pat => 'SHum'    , level => 'undergraduate', short_for => 'Sarjana Humaniora', },
    { pat => 'SIKom'   , level => 'undergraduate', short_for => 'Sarjana Ilmu Komunikasi', },
    { pat => 'SIP'     , level => 'undergraduate', short_for => 'Sarjana Ilmu Politik', },
    { pat => 'SKed'    , level => 'undergraduate', short_for => 'Sarjana Kedokteran', },
    { pat => 'SKel'    , level => 'undergraduate', short_for => 'Sarjana Kelautan', },
    { pat => 'SKG'     , level => 'undergraduate', short_for => 'Sarjana Kedokteran Gigi', },
    { pat => 'SKH'     , level => 'undergraduate', short_for => 'Sarjana Kedokteran Hewan', },
    { pat => 'SKM'     , level => 'undergraduate', short_for => 'Sarjana Kesehatan Masyarakat', },
    { pat => 'SPdI'    , level => 'undergraduate', short_for => 'Sarjana Pendidikan Islam', },
    { pat => 'SPd'     , level => 'undergraduate', short_for => 'Sarjana Pendidikan', },
    { pat => 'SPdSD'   , level => 'undergraduate', short_for => 'Sarjana Pendidikan Sekolah Dasar', },
    { pat => 'SP'      , level => 'undergraduate', short_for => 'Sarjana Pertanian', },
    { pat => 'SPsi'    , level => 'undergraduate', short_for => 'Sarjana Psikologi', },
    { pat => 'SPt'     , level => 'undergraduate', short_for => 'Sarjana Peternakan', },
    { pat => 'SSen'    , level => 'undergraduate', short_for => 'Sarjana Seni', },
    { pat => 'SSi'     , level => 'undergraduate', short_for => 'Sarjana Sains', },
    { pat => 'SS'      , level => 'undergraduate', short_for => 'Sarjana Sastra', },
    { pat => 'SST'     , level => 'undergraduate', short_for => 'Sarjana Sains Terapan', },
    { pat => 'SSos'    , level => 'undergraduate', short_for => 'Sarjana Sosial', },
    { pat => 'STh'     , level => 'undergraduate', short_for => 'Sarjana Theologi', },
    { pat => 'ST'      , level => 'undergraduate', short_for => 'Sarjana Teknik', fields => ['engineering'] },
    { pat => 'STP'     , level => 'undergraduate', short_for => 'Sarjana Teknologi Pertanian', },

    { pate => 'MAk'    , level => 'graduate'     , short_for => 'Magister Akuntansi', },
    { pate => 'MA'     , level => 'graduate'     , short_for => 'Magister Agama', },
    { pate => 'MARS'   , level => 'graduate'     , short_for => 'Magister Administrasi Rumah Sakit', },
    { pate => 'MArs'   , level => 'graduate'     , short_for => 'Magister Arsitektur', },
    { pate => 'MBiomed', level => 'graduate'     , short_for => 'Magister Biomedik', },
    { pate => 'MEI'    , level => 'graduate'     , short_for => 'Magister Ekonomi Islam', },
    { pate => 'ME'     , level => 'graduate'     , short_for => 'Magister Ekonomi', },
    { pate => 'MGizi'  , level => 'graduate'     , short_for => 'Magister Gizi', },
    { pate => 'MHI'    , level => 'graduate'     , short_for => 'Magister Hukum Islam', },
    { pate => 'MH'     , level => 'graduate'     , short_for => 'Magister Hukum', },
    { pate => 'MHum'   , level => 'graduate'     , short_for => 'Magister Humaniora', },
    { pate => 'MKep'   , level => 'graduate'     , short_for => 'Magister Keperawatan', },
    { pate => 'MKes'   , level => 'graduate'     , short_for => 'Magister Kesehatan', },
    { pate => 'MKKK'   , level => 'graduate'     , short_for => 'Magister Keselamatan dan Kesehatan Kerja', },
    { pate => 'MKK'    , level => 'graduate'     , short_for => 'Magister Kedokteran Kerja', },
    { pate => 'MKM'    , level => 'graduate'     , short_for => 'Magister Kesehatan Masyarakat', },
    { pate => 'MKn'    , level => 'graduate'     , short_for => 'Magister Kenotariatan', },
    { pate => 'MKom'   , level => 'graduate'     , short_for => 'Magister Komunikasi', },
    { pate => 'MM'     , level => 'graduate'     , short_for => 'Magister Manajemen', },
    { pate => 'MMT'    , level => 'graduate'     , short_for => 'Magister Manajemen Teknik', },
    { pate => 'MPdI'   , level => 'graduate'     , short_for => 'Magister Pendidikan Islam', },
    { pate => 'MPd'    , level => 'graduate'     , short_for => 'Magister Pendidikan', },
    { pate => 'MSAk'   , level => 'graduate'     , short_for => 'Magister Sains Akuntansi', },
    { pate => 'MSE'    , level => 'graduate'     , short_for => 'Magister Ekonomi', },
    { pate => 'MSi'    , level => 'graduate'     , short_for => 'Magister Sains', },
    { pate => 'MSM'    , level => 'graduate'     , short_for => 'Magister Manajemen', },
    { pate => 'MTI'    , level => 'graduate'     , short_for => 'Magister Teknologi Informasi', },
    { pate => 'MT'     , level => 'graduate'     , short_for => 'Magister Teknik', },

    # XXX spesialis2x dokter

    # note: spesialis dokter bisa mengandung tanda kurung, mis: dr. Budi Budiman, Sp.P(K)

    );

my @foreign_prefix_academic_titles = ();

my @foreign_suffix_academic_titles = ();

my @first_names = (
    { pat => 'm[ou]hamm?ad|m[ou]h', sex => 'M', religion => 'islam' },
    { pat => 'm', sex => 'M', religion => 'islam', conf => 0.25 },
    { pat => '\S+' }
);

#==CHINESE==

# There are about 3% chinese indonesians (but some say less than 1%). Most use
# Indonesian/western names, but some do use Chinese names (in romanized/latin
# letters).

# Many of these names are in Hokkien (the majority of Chinese immigrants in the
# Dutch East Indies) written in latin using Peh Oe Ji romanization + Dutch
# spelling influence. u is written as oe, c as tj, i as ie, y as j, j as dj
# (e.g. ciu -> tjioe, nyo -> njo, yeo -> jeo). Btw, th in the, thio, etc are
# actually nasal in Hokkien.

my @poj_syllables = qw(

);

# WADE-GILES (MANDARIN)

# popular until 1970s. in this list the diacritics and apostrophes are removed.

my @wade_giles_syllables = qw(
a ai an ang ao cha chai chan chang chao cheh chei chen cheng chi chia chiang
chiao chieh chien chih chin ching chiu chiung cho chou chu chua chuai chuan
chuang chueh chui chun chung e ei en eng erh fa fan fang fei fen feng fo fou fu
ha hai han hang hao he hei hen heng hm hng ho hou hsi hsia hsiang hsiao hsieh
hsien hsin hsing hsiu hsiung hsu hsuan hsueh hsun hu hua huai huan huang hui hun
hung huo i jan jang jao je jen jih jo jou ju juan jui jun jung ka kai kan kang
kao ke kei ken keng ko kou ku kua kuai kuan kuang kui kun kung kuo la lai lan
lang lao le lei li lia liang liao lieh lien lin ling liu lo lou lu luan lueh lun
lung luo m ma mai man mang mao mei men meng mi miao mieh mien min ming miu mo
mou mu n na nai nan nang nao nei nen neng ng ni nia niao nieh nien nin ning niu
no no nou nu nuan nueh nung o ou pa pai pan pang pao pei pen peng pi piao pieh
pien pin ping po pou pu sa sai san sang sao se sen seng sha shai shan shang shao
she shei shen sheng shih sho shou shu shua shuai shuan shuang shui shun so sou
ssu su suan sui sun sung szu ta tai tan tang tao te tei ten teng ti tia tiao
tieh tien ting tiu to tou tsa tsai tsan tsang tsao tse tseh tsen tseng tso tsou
tsu tsuan tsui tsun tsung tu tuan tui tun tung tzu wa wai wan wang wei wen weng
wo wu ya yai yan yang yao yeh yi yin ying yo yu yuan yueh yun yung
);

# HANYU PINYIN (MANDARIN)

# hanyu pinyin usage for indo chinese names is still rare, but i expect to
# increase in the future.

# of course indonesians don't use diacritics like ü, when they encounter one it
# will probably be replaced by u (admittedly wrong, should've been by v or uu
# or even perhaps ue, but the case of names having this is very rare).

# not included in this list: lü, lüe (replaced by lue), nü, nüe (replaced by
# nue)

my @hanyu_pinyin_syllables = qw(
a ai ai an ang ao ba bai ban bang bao bei ben beng bi bian biao bie bin bing bo
bo bu ca cai can cang cao ce cen ceng cha chai chan chang chao che chen cheng
chi chi chong chou chu chua chuai chuan chuang chui chun chuo ci cin cong cou cu
cuan cui cun cuo da dai dan dang dao de de dei den deng di dia dian diao die
ding diu dong dou du duan dui dun duo e ei en fa fan fang fei fen feng fo fo fou
fu ga gai gan gang gao ge ge gei gen geng gong gou gu gua guai guan guang gui
gun guo ha hai han hang hao he he hei hen heng hong hou hu hua huai huan huang
hui hun huo ji ji jia jian jiang jiao jie jin jing jiong jiu ju juan jue jun ka
kai kan kang kao ke ke kei ken keng kong kou ku kua kuai kuan kuang kui kun kuo
la lai lan lang lao le le lei leng li lia lian liang liao lie lin ling liu long
lou lu luan lue lun luo ma mai man mang mao me mei men meng mi mian miao mie min
ming miu mo mo mou mu na nai nan nang nao ne ne nei nen neng ni nian niang niao
nie nin ning niu nong nou nu nuan nue nun nuo o ong ou pa pai pan pang pao pei
pen peng pi pian piao pie pin ping po po pou pu qi qi qia qian qiang qiao qie
qin qing qiong qiu qu quan que qun ran rang rao re ren reng ri ri rong rou ru
rua ruan rui run ruo sa sai san sang sao se sen seng sha shai shan shang shao
she shei shen sheng shi shi shou shu shua shuai shuan shuang shui shun shuo si
si song sou su suan sui sun suo ta tai tan tang tao te te tei teng ti tian tiao
tie tong tou tu tuan tui tun tuo wa wai wan wang wei wen weng wo wu xi xi xia
xian xiang xiao xie xin xing xiong xiu xu xuan xue xun ya yan yang yao ye yi yin
ying yong you yu yuan yue yun za zai zan zang zao ze zei zen zeng zha zhai zhan
zhang zhao zhe zhei zhen zheng zhi zhi zhong zhou zhu zhua zhuai zhuan zhuang
zhui zhun zhuo zi zi zong zou zu zuan zui zun zuo);

# BASTARDIZED PINYIN (pinyin mandarin + adjustment for indonesian spelling).
# e.g. zhi dao -> ce tau, qing -> ching, xing -> sing. you see these in
# ktv's. inaccurate but maybe some names are using this? probably not.

# YALE (MANDARIN, CANTONESE) - created for english speakers, follows more
# closely on how an english speaker might read it. unused in indo names.

# TONGYONG PINYIN (MANDARIN) - taiwan, political, since 2008 unused, rather
# weird too (e.g. zhou -> jhou) and not used in indonesia.

# 2 pinyin or 3 pinyin -> chinese
# jika 3 pinyin kadang 2 terakhir digabung, mis: liang rongyao
# -> split ke modul lain? (tapi low prio, tar aja kalo udah jadi kita refactor2x)

# 2 pinyin digabung? hati2x bisa banyak false positive mis: a+ni,
# bu+di, li+na (walaupun beberapa memang indikator lemah juga bahwa
# namnaya chinese)

# beberapa nama peleburan yang merupakan indikator lemah chinese:
# salim (lim), ... [ref?]

# gabungan nama indo + marga: dedi lim, atau (less common) marga + nama indo: sie liya

# (HAKKA/KEJIA)

#
# (HOKKIEN/FUJIAN)

# JYUTPING (CANTONESE/YUE)

# should probably use CPAN module like eGuideDog::Dict::Cantonese?

my @jyutping_syllables = qw(
aa aai aak aam aan aang aap aat aau ai ak am an ang ap at au baa baai baak baan
baang baat baau bai bak bam ban bang bat bau be bei bek beng bik bin bing bit
biu bo bok bong bou bu bui buk bun bung but caa caai caak caam caan caang caap
caat caau cai cak cam can cang cap cat cau ce cek ceng ceoi ceon ceot ci cik cim
cin cing cip cit ciu co coek coeng coi cok cong cou cuk cun cung cyu cyun cyut
daa daai daak daam daan daang daap daat daau dai dak dam dan dang dap dat dau de
dei dek deng deoi deon deot deu di dik dim din ding dip dit diu do doe doek
doeng doi dok dong dou duk dung dyun dyut e ei faa faai faak faan faat faau fai
fan fang fat fau fe fei fing fiu fo fok fong fu fui fuk fun fung fut gaa gaai
gaak gaam gaan gaang gaap gaat gaau gai gak gam gan gang gap gat gau ge gei geng
geoi gep gik gim gin ging gip git giu go goe goek goeng goi gok gon gong got gou
gu gui guk gun gung gut gwaa gwaai gwaak gwaan gwaang gwaat gwai gwan gwang gwat
gwik gwing gwo gwok gwong gyun gyut haa haai haak haam haan haang haap haat haau
hai hak ham han hang hap hat hau he hei hek heng heoi him hin hing hip hit hiu
hm hng ho hoe hoeng hoi hok hon hong hot hou huk hung hyun hyut jaa jaai jaak
jaang jaau jai jam jan jap jat jau je jeng jeoi jeon ji jik jim jin jing jip jit
jiu jo joek joeng juk jung jyu jyun jyut kaa kaai kaak kaam kaan kaap kaat kaau
kai kak kam kan kang kap kat kau ke kei kek keoi kep kim kin king kip kit kiu ko
koe koek koeng koi kok kong ku kui kuk kung kut kwaa kwaai kwaan kwaang kwai
kwan kwik kwok kwong kwui kwun kyun kyut laa laai laak laam laan laang laap laat
laau lai lak lam lan lang lap lat lau le lei lek lem leng leoi leon leot li lik
lim lin ling lip lit liu lo loei loek loeng loet loi lok long lou luk lung lyun
lyut m maa maai maak maan maang maat maau mai mak man mang mat mau me mei meng
mi mik min ming mit miu mo moi mok mong mou mui muk mun mung mut naa naai naam
naan naang naap naat naau nai nam nan nang nap nat nau ne nei neoi neot ng ngaa
ngaai ngaak ngaam ngaan ngaang ngaap ngaat ngaau ngai ngak ngam ngan ngang ngap
ngat ngau ngit ngo ngoi ngok ngon ngong ngou nguk ngung ni nik nim nin ning nip
nit niu no noeng noi nok nong nou nuk nung nyun o oe oi ok om on ong ou paa paai
paak paan paang paat paau pai pak pan pang pat pau pe pei pek peng pet pik pin
ping pit piu po pok pong pou pui puk pun pung put saa saai saak saam saan saang
saap saat saau sai sak sam san sang sap sat sau se sei sek seng seoi seon seot
si sik sim sin sing sip sit siu so soek soeng soi sok song sou suk sung syu syun
syut taa taai taam taan taang taap taat taau tai tam tan tang tap tat tau tek
teng teoi teon ti tik tim tin ting tip tit tiu to toe toi tok tong tou tuk tung
tyun tyut uk ung waa waai waak waan waang waat wai wak wan wang wat wau we wi
wik wing wo wok wong wu wui wun wut zaa zaai zaak zaam zaan zaang zaap zaat zaau
zai zak zam zan zang zap zat zau ze zek zeng zeoi zeon zeot zi zik zim zin zing
zip zit ziu zo zoe zoek zoeng zoi zok zong zou zui zuk zung zyu zyun zyut
);

# liong? leung?

# daftar marga batak?

# daftar nama indikator sunda: t?atang (m), otong (m),

# pola kemiripan depan dan belakang? tatang suratang? (we need indo syllable breaker first)

# if scheme, then some extra info is available, e.g. in balinese:
   # birth_order_title? caste_title?

my @balinese_birth_order_names = (
    { pat => 'putu|wayan|gede' , birth_order => 1 }, # but can also be child #5, 9, and so on
    { pat => 'made|kadek'      , birth_order => 2 }, # but can also be child #6, 10, and so on
    { pat => 'nyoman|komang'   , birth_order => 3 }, # but can also be child #7, 11, and so on
    { pat => 'ketut'           , birth_order => 4 }, # but can also be child #8, 12, and so on
);

# kalo konflik, ambil yang wangsa_level tertinggi, custom sort order
my @balinese_wangsa_names = (
    { pat => 'i'                     , wangsa => 'sudra', wangsa_CL => 0.01, gender => 'M' }, # only if no other wangsa indicator, e.g. I Gede
    { pat => 'ni'                    , wangsa => 'sudra', wangsa_CL => 0.01, gender => 'F' }, # only if no other wangsa indicator
    { pat => 'ida bagus'             , wangsa => 'brahmana', gender => 'M' },
    { pat => 'ida bagus'             , wangsa => 'brahmana', gender => 'M' },
    { pat => 'ida ayu'               , wangsa => 'brahmana', gender => 'F' },
    # there's probably some (weaker) gender indicator here too
    { pat => '(?:c|tj)okord[ao]|anak agung|sagung|desak|dewa|gusti', wangsa => 'ksatria' },
);

# from scheme, e.g. in balinese i/ni, ida bagus/ida ayu. in sundanese/javanese: raden/raden mas/...
# from strong indicator in first name or other names: muh/m/muhammad, st/siti, ... bin ..., ... binti ...

# kita bisa choose utk pakai pattern tertentu aja, atau skip some

my @patterns = (
#   { name => 'balinese', pattern => '(regex)', ethnic => 'balinese' },
#   { name => 'salutation_first_last', pattern => qr/^($salutations_re)\s+($first_re)\s+((?:$last_re+))$/,
#     parse => sub { parse_salutations($_[1]), p_first($_[2]), p_lastnames($_[3]) },
#   { name => 'first_last', pattern => qr/^$first_re\s+$last_re$/ },
#   { name => 'first', pattern => qr/^$first_re$/ },
   # XXX chinese?
);

# jika terjadi konflik, utk array gabung (mis professions), utk level
# pake yang tertinggi, untuk sex =>

# fx = fransiskus xaverius? taruh di mana?

# first
# last
# salutations
# prefix_titles
# suffix_titles

# from lingua::id::genderfromname -> from first name only

# gender_guessing_confidence_level(?)

=head2 ATTRIBUTES

=cut

has name => (is => 'rw');
has academic_titles => (is => 'rw');
has salutations => (is => 'rw');
has first => (is => 'rw');
has last => (is => 'rw');
has middle => (is => 'rw');
has format => (is => 'rw');
has config => (is => 'rw', default => sub { Lingua::ID::NameParse::Config->new });

=head2 METHODS

=head2 parse($name)

=cut

sub parse {
    my ($self, $name) = @_;

    # preliminary cleaning
    for ($name) {
        s/^\s+|\s+$//sg;
	s/\s+/ /sg;
	# s/\s+\W\s+//sg; # "foo , bar", "foo . bar", "S . H"
    }

    for (@patterns) {
        if ($name =~ $_->{pat}) {
	    print $
        }
    }

}

__PACKAGE__->meta->make_immutable;
no Any::Moose;
__END__
=pod

=head1 NAME

Lingua::ID::NameParse - Parse Indonesian names

=head1 SYNOPSIS

 use Lingua::ID::NameParse;

 # OO-style
 my $n = Lingua::ID::NameParse->new(name => "drs. Puput Amir, M.E.",
                                    config => {gender_from_first_name => 1});
 print
     ($n->gender eq 'M' ? "Bapak" : $n->gender eq 'F' ? "Ibu" : "Bapak/Ibu"),
     " ", $n->first, " ", $n->last, "\n";
 # prints Bapak Puput Amir, since Puput is a weaker gender indicator than drs.

 # procedural style
 my $n = id_name_parse();
 print $n->proper, "\n";

=head1 DESCRIPTION

This module can parse a free text Indonesian name into components like
salutation, academic title, first/middle/last names, etc. It also
tries to extract various aspects indicated by the name, e.g. gender,
religion, ethnicity, profession, etc.

It understands common name patterns of some ethnics in Indonesia like
Balinese and Javanese, e.g. with Balinese name you also get birth
order and wangsa/varna information. It also understands Chinese names
(e.g. Sudono Liem, Zheng Ge Ping), which are quite common too.

It understands Indonesian academic title prefixes and suffixes (S.Si = sarjana
sains, MA = magister agama, etc.) as well as English/American (MA = master of
arts, BSc = bachelor of science, etc.)

You can tell the module to guess gender from first name, in which it will use
L<Lingua::ID::GenderFromName>.

=head1 SEE ALSO

L<Lingua::ID::GenderFromName>

=head1 AUTHOR

=head1 COPYRIGHT AND LICENSE

=cut
