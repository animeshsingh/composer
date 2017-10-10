ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ;)�Y �=�r�r�=��fRNR�TN�Oر���&93��|��ëh��x�d���3 9�p@υ��|©��7�y�w�� 3��ɒ��5� ��Fw�F70����&�*n���m��vM-�k���D�2��I��Z²}$��hL�d)">�hX�<�=�_X\ہ �vt{>ܲ���A��cs<��q�����"{�� �e��&��7Ӂ���&l���S�Po�:�k���2�VGVh�|L�h[���  �m	[�6���!��[�l!� %��t�C��e���� ���h�Uhi6��N����5�@2�A�CB�ė�\ҷ	�"d)ZK7��iaà+#�BmX8��өE�H#��4��݄�l@�D�;���'�ٸy"&R2h���Z<��?l����.꾆l��ێ7!��H�@�51(,���&>�����z��(;�b�n����C�&���Yԡa/���v�4�a�4d�[:��Gt�˵�z�j�ۡ��9�.`�m ڃ��O;-��B���'V��`�UZ��v.E�Xu1_>\�.V[����8m�1�;�y���sF��C7G7�6�����G��Qil�)vafO��'�a�)��'����1��k���#�}�DN[MfW4T���[t� ˄���Lڮ>,�����+�
�P'@�?��нӠN^,����2���X�����Ƚs2�|��ߌ�wq�p���k�nܕ�����%��$,K�(�z1&Kѵ�����PU7CUh78��� ��9P5�O�-�b��W	����|pTJ��
��<����߃vW#�B��A��^K�e��Sݧ��Y�_��������/����6T�����66�;���������������M�p�{]�r�D��B0��N� ��,Pfu6p0�#�9G6��-�W� ��q;m�]���|�mK�@���X.bU"�u[��i�����;��w� �&Z��V�&64���ذ��=�oJy�:lM�9%���"�f��5���(z�Dv��h�ϏpY5��Tpxj���p�ڔ���0��Ivê����z�o�ơ������;���F�=�AO�C������d"R�� ���p0�'��@�R��Ayx�="�?�O=�!-�� ����&���?�0R���]]�%��D�N��� 
�z�_E���'�zy���08耦n ��Pw�D�rMS7룗B67ld;��|���Cq��s��h� �q��k�-�&E�A~�x�EQ�d)@j~�У�!!{���ҏ D6���3W�	qi�8�.ͥ^����	Y�B�Q�}:��� ��Qco�l m�E�p�<6f�#�}�&�m9�^�E��1�=b�i�=��;�Cf����DefYu*#����XE {S�M��dl|}pi�$���.}:ر"m�{]��+���Q�5L>��(�;,�w�CAHu@�����g~<�}�w�3��6؈�G��?�<%�or>��	t�N����Od��0�Q�$�2��Q�4�M�N� �Z6_�NQzC��z��C���#���M���_j�a�� ���-�?��Fb���������2C�GsyO4��(K�i��翫)�����xޙw���h��gL�z����s���Z��9i�eQd� ��z\*W���儫�����R�3Y���L��=���3x��j����Ĝ��%�r3J��K~8N�ʹ����m���	 ���5m�$N���(/l��_��50�`Ǐ*�a��8	F�x�t�a��T��[�(�ʇJ.�>8���zl�b<��,�޼օ��;b���-���Oo�@����,*�0�x�<�Ix��੅���`�%a��\V�A����n��,���􊹥@�m�,���N ��J���_��K�\�ł��R�9Fl�������;9?��.�����$����j������������ .���(L��pl���(���ܓO������M2!����j��q�xȠo�׫Ν�����Nc������?_���,��ù��z��������t�����G����?����J����4݅c���-�Ȳ���-�t���45;��x u��G}���N�'�B�RJ����2�h����(���Dm��:���}��%=��O����AF�{F�w"��O�_�U��V,Ԧj��X�3a�F��E���;M�РAR�X-�j����̆��+�6�2z�S��3����"kL�V& 㯃��9���{�L�N��5>�&��@�\�\��r���.A���L�>�	�#���+)w_�A�|���
W�C�q`�[K!��B�x�Z�����q����k��� Ġ����V�*2;�i�_߽��:�d���T���L�#rtJ��Hx��+)� �o5� �el����C&�� ��S|�k��U�_��tS���K����i��c�u��J�]��A^�s�����,������=��:�4�	{H�0��X��$�@{VNm�X ( !8�e�i��,`�5�wm��B��m�#Hd��7��vы��K3�-ef��+�e�`���/Ɉ��O��N�1�F�_�Ʉ>K3q�	$fdؘJ43s���d�cL4˅1�թD2O�v����2���˕2�g���9"~�̬�KhS�L_"��Yɼ[�Ռ��/(<�7_nl�+�'и��������*ʭ���y�SйXF�N����B$6}�����ϕ����>p������?�������?Lٟ~B᪠ʲߪ��*�qX��du+�֪qI�b�"��r��*��x\�ƶ"Ru+������|�M#�P6���;��6t�Gd�����+j�6}���ش���nk�7���X�Q������_��D��_}���s�g������o~����#�����͉E6������o��0%D��`���������g�+����ފ������^�WS>q���&oBc��/]�9*����*ʕ��O J��F�;�ARz��%kd��C/�O�^Om:Y�o_�^��l9��qzDe��E�5A�m����V�T����e)��LD�4(�aYP�����0e9#$�!�+^EdY�Q+@��%���
 �.Ur�\R��Y�;3��%��ɤ�&�J7�P깒Rp���Jd{�ML��Q�&맹=|��<���^��	��Uģt��O�/җJ)Q/T�d�Шf�V5�څ'�̹r�=S+�c�LOdߙj+�J�婴u��(o<\Ig㽳˴{��Ѩ�I�g��yU.vS
�`�Th�3�[3!��������yN�Wr�A%'�кsV'�ޙ'�j�hw����q��Mw_]�+y2p�w�D~�(elxr�Q[��i%}�O��_���#)���g�ӓ�9|S8�^�k��� �n��xRr�ID!ca��e3���0�[�N��8##��g���r^�+�t6��?wӻ��SYwk�"Q�͋r%��;���t��<�DSdNJ�׉]s�yr3JG�S���e�V��H>v;kwS[�r,g��R�LN�����y����+2�­���n���n=���X��	���V�%��i��\���'��\�e�A7��%��L�����>�[Dr�����h^�^Gv���y{Ff0�u%�>J�I��+Fߙ�t�c�r��-x���C��E,����yr�=�w�Z����#{Q�*��i8��m��u��[~g�9��BA�%�x���J��;��|����|��������Y�����1c�?��S���9�Q�
�G`����(�����Y�����|�������}>w��eE�d��~���:�o%e�O:,厉q {�SV���粻�&+�lt"+t!���ź ����=���z�}̝(�BY|�
����R/K{ESr��J*J��$��Q���5/30{qy,��~QE�ǜ|�<�K�^$c�������Ɖy��[9��U%�:r{��݊�Z(�o�|�17�|�;��G��S~�_�n�#k������[��]_�G��/Ͳ����+)���(��K���L������I�8<
I)E5U�+i�Z�L�V2��'u7d��u�[��>Ȝe��4R����8S�70V�q[���o^:��2�î�o��!��6�L)���q>�����N���LKjz=؃7���%������WS��$n�,�K��7��a���A	1�Ђ�ey�z������ܚ��m0�K�`��
��xHV��A �PM7u1�k4���%;��A��N���QK����r�,��CZ�~�S|>�� �#8#
 �p��6��b��M�b��m��Y,#�k:����e!Ht�1���X��↱2�1�]l;�/��s��<��F�=�8y(���*��Hr��Z|��I�li��`����d�	��wu]�xݡ?v5&B42����v-�g�]��U�<���mХ��d��H� 2|�A/=m�0�xX��@hhY�G	�Jc��&�����z���S���ŀ�
C���ɔ��>�:�^l�J�i?��:EA^����NzpO��6=�x~��hl2^���9~�hB��b��X����3D8Yh�d��/����Kov�I��#���WW�A��� ��Ir��/D�禭�k�>�4\����[���!jzIj&�B>͗�Bv�
Z������j;=�5�I���&����̉���2>�V�Q��84L�=$���4�)�
,����,U�5������>��B\;�݋�\@D�-l!)a�f �:�i5�\6z>B&xp���Zb`�$�&���M�V]x��5��8�S����%���G9d�<g�6_zW�i�"�����x^��7}t~7�����'T���X��x���<��fpB�h�pmd��ŐM*�r�YTTõ���b�6�T�����K��ɚR�������;�.W�D\6Y�	�
$c�R�]}��1�b���t�$9��5xӶ�e���6�+F*CV�C�̧�'st��}1���S�#��(��T&$��V U�>��b���1�@���<G��S�d���udmُ�,����]K��XZ��i����)R�
f�L7�K����2%�;�s�<�'�+'v'���N�d��B���@Po���Y��alF Do���s�����B���[���}��9���_����!ls�O�����<~%��~�g�?��.�ŷ'E���?W������o���~G>Ǒ���������譣C�����5t1�ʟ~�Bѐ�H��*�X�
G�r�)IaM<#íA*dT�	�lK�!��_H�x���~��|���~��W~������䏞��8�{�],�;X��G�^�h��_����� ���z/��� ����?"_J���=|�0�O��v�m��{��n��b�S.Z�����n4Z>6�t,��z�l2,}�t:��~/�/X��,�
�-��W!>tUC`Zv�P؍��Z3�XsA��ٝ�V&6�.iB���B�@
��d=[��
�3DH	���N���HkQ(
&g���1[��ǍAl�h]�X74|��L\�����ns����L(�̈́	3�rs�k�T��*n6��i��B�4���E�y�W/��3^����3l��׏��iz���y͠:� S<���S|id�|�k��t"�.T���~�.�쬄��3%Y,SVF�+e�B3Y��"��)�����$����5?]O"L�A��	3�v�I�ْC�Y!��B')�yD�:)��"}.��F�4��05+��"S����yx���*�4߉/&=T+��.q�@汨F.��L��w��.����43���dMk�IJ�UKe�H'�Qz6nRbnn�'��X9�����������^�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� ��0�.�f)E���O�J�Õ�Rb��9��7��x1���8��60�.��q/jgE�s�*'�K螻�<R�[��۩����@���������A\�S붗yj:Ċ�Hz�3D渁gC�iT�r���f	~����ܔ	�jiZ=G0��S�DY
7��&��	N���Hj��j�����&�'����8c+s�ٲ�#t-��Itoi⭈�Sf�[87/T?:5�r82�1J�a�C�9�)�fbX�vb��(N��<]�D��eS}BᒹӊJ��ܤ�Gd��J�~�̢Ԁ��˼[�w��ہ_8z=�A�(���G�=z��r�?� ���u���n�}���o���&���G��Z>	�s������G�N>��^�:5]���/z�����x#�ׁ�����[�(������+�o<��c>��������<��+EYfi�2YZ�|ވ�r��2y���r�b��ۭ-�/�/Z�'X����8���-3a�3I��Pr!���Ky������\�-�
&�qD�ilJ����]	���o� �D����tZ�������x�BH5J����Ȕ�S�cv�W������T��ln���z�X`��z�mQt|�TZ�8i�F�֣��6H�;*?NWFx�Dj"���L�x����+�4k9M�S���4K��� #�@��P!iAf;��3R�[T�F;*]n'���HĐ��sK�l=Qu�4_�/�SdMQv�)�e8Z�՚���k�&.v˃A�D�	�k9˂�`d-�~�l!���9m�����]f�tÚrܘ3U���-^�J�d�G����ǿu%�ā����B=��|yP�����δ[\n�����e��]���4�K���� �u�#�q��"��"��Y���j#�o?c�gf��e\vGn��.�#����u�{����7�ڴ���
G�[�e:��Ɇ�Vyc֑�|&Oԓ�8�Vla8,)�zܯ���X�.}6�0Ōb4��í��y���è���F��J��lV��*\�ڴe�6��M��6���x��Gt�:��Sȇ�N"5�u���8R힟Z{:��A�|�W:�dZ�R�%��b��҂4=mբy%٨(�T�/��1�.Efi�	�ys �7.5/E�a:��&S�v?�Ry.B�[Åip�X�1#�x�E��³��y%OdE�H+E"dg��xXS#S�1�+��-��l��U$#3I;�d�p�G����4�2An{�*de_�L$k;�*�"0�]�����W+�Rz*�+����X��R�C��Vp�	���c.���*�5
%�Cp�cq�K+ճ(�<Ki���M��et:S��;�
q5��)g��y�)�����E}h:��*��=����	җ�BJܐ��Ba�nF-E�N���|��r�J7D�V����l��5�T�Q���a2j��4�cSi�4���%��P6�-�F�U��r���.c&�.���_|˲���w��M7��ٍ�/Z���.�����<tlѢ���*8r3>�e�g�i�2ԧ��+����7��6�<F~���V��.��{����ϟ?�?|�<�����#ڎ���D� V�>E�΀oISeۇ�]�@\ӛĕ^)�y�y��t���:#��� ���#2�q>A~����)P��8�8uG�k��{�y䁳8�,O]W� x�|�`���ҡG��"�2+G�k��t�t�� Od̯����������H/���G/8���A����ד ���
�;��ts�����T�
�/�Vf��z�;�0V%���4���Ŏܸ��;
���4���3"�_���926ifw��]���H���I�S�k�*��9?�t�l�㧫���3�z�폭�U^Ѣת����U�ɎN��h���s�cj|oo==VG_Q�lH��z?<�HPP� !=����%-�8F�G10E�6��'
,Բ� z& 1�"v*�2H}c�]\ �3�w�ؤaв�S�� �fq.���Ի��&������ �˩O��/O��jNW@���+��V��&>$�MO��`������z�_ g�ADVТ3��1���X뭭u�v �w�W���h~�ʬ��A�|��,] R�̢�'���g�*�L�*�?Yu�b[�h���%���q��{��юW�]�Ip��:�z�"�gm�}��e�tb���2z��$��6�O�aKK�I�8�j8���jQ;�+��@��z!�g䊉+�������ԃ��?�0Ӱ�M���	�����* �.6��u��~�_�/�LF�}=w�_�1t[=:�� ��`S!z,-{�Q�k28� ނ��>�)OB�P��Zm6����6o(�� )�O◧q���粫k@W�g/"��B�m��p~в���dM`e�%�s%k�hٺ2�^���-%O�{��Q�� 8\�a�n]\*��/ ���P�$U�/cX%m �cp.�bz��v_�a�Nv �ݶ��^q�Eo���#�c��� �	����ӔT�=rQ�@�J�&(�񟅜	}�vp��,�]� _�.� Q�6����*�u�ii�~��@����`WV�ce2����C�&͝�\2�o�nZ�<�t;h�Y�$�s�>�n�	r�#��[�E ���D�4kX򪋫�=]�8�	�e��X4(0����.�lto�x����c��� �ކ�8m1���j�i"�-B���W�Z%kݶ�����jBH��:3r
����23��z�:��:�k�'ش_@���1���^�U�͉�	�C��	�z?붉�ֆ�Ɖ�S�9�a1b%)��������_��$�-4egCi�@'(�w���w\qpl��b��Iߑ���j�����
$��܏:�����������������m�����+���b3�'�`��}$��!>!>A@j˶Jv�ܰe%�vr��h �oó�g���"?��g 2�3T1Z�����Q��+\����*vt��R��Y��\��ծu��'���ӱrEC�\�f�H!K�I5	Ij���HdH	�m�j�ZJ�#m\��f��?F��v���p8�H%��}[�����DX�ì�gN,�*�����l�Ƕx�O�'O�Pa̐k�bǂxf��W7��IM����&�bY�qB	�0)&IE�cJ�RQ%$5eBB
Y3�)ሂK��X|Ҵ�����c3�D���̲��o���7�;�$�亣q��	Ovfߓ�E�V�]����wd��cw���msE�+ZT��\�Μer�W�2�d�9�\��/�\�f�"W*=àu�]��[�K'�r�3x�E�����_pa�A��P���3���U�A���.��{��U@@�[;�3�Π���vF�\�'-���i���Z�3��b��-��o�A�6io��;]k�nxl熉Bw�!���V7g�j}��nz��0�b�ߊ�y!��sEy��&��W� t�>���l<Ǯr�<�rL9���"�qY6����P���(
�Y�3i�N�CǶz������Yy��?��m�&<Z�����ZES���e|�,ˉ�\�T�F��e�3����F�X�>���d=�k��bj�g@�=fY-�&��%�9�'K�4C��gq�e.�ϕ�)�q����N�1��E�/�A=�-�O�8��L>kK��\����"�xc0��EL���:Mݝﯡ���,���vs��:߲]��d�X��`��2V��~��0���{�F.u���N���ͮ��;V�ߊw�#�9+3V���@!t����3��m����zq`�&�f�_�$9��G���o��6n��!�|'뿏���KF�f�CD?��>�+���ķ�c���H/��MoI�	zH{H�X�[�*t��{I���'plS����A��#�K�ß��i�ʦ}��K������_ �����hhh^���f��W��#w��:�{I���9&Y����E�v$*����l�Ȗ"K�X$��*�EۡV�����pTib���	�u��,��j�Wa���m���k/�g�m�ɼq�O�}\S��:iet�:G�+b�M	�;�4��u%?��8ɍ��$P=��E��"m.U���rH!2��@��E��-�=�ޖ�����y�?����ޤS)N�Z*^	a1eV��a�;F5��؟�����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g�������wm]jb[��_q���~y8c|�TDP��r "�@QQ~��U1�vWRI��dͧ��TE��\s�57IA��
�Q�pT'�����! ���'�0�Q	���m�����H�?�0��_���(����IB�o%x���n������t������a�:�/�Bz��,k��)��:��O�Gv?o�aF�x���m�{��gQ�_OfU0�������'��H��J
�Z��Իi3���^3W=�P8�i��Dy0��d�|�V�k����*�e�e�lbW����e���,���>�k����}���z��j�!��w�n�y]�X�4{��Iz�M���"����)_����]�����;��)I�e��8��|*�R�cYkO֡˰�il�������)X�>����E��Ys��v�W3�����迗Q� ������C����_��H��H��O�H8��@��?A��?�[�?�$�*���˓��������C��_����
 ��Ͽ	��
�?��ׇ7���k�|���3霊�A����[�d������[������������.���e=�V0��P�yւu4���n4#}��;x�겚�	ņ���$-.�~���9ݟJ� �C����i��KY�����DC,^�z�u'@6D��_K��$[���i�c�>������Z�B���$�S�Kn#%����ʘr{ɤ$����6n���w�[/B����b�'�Z�m�&��ґ1ژS�0���x���U ���.�!�GP�� ��o���S_�^��_	P���< �p��g��3�38#A�Gt�\�aH���r!I!N�l�P�g|?P��g��P�W������=O_�)4[M���4�O�R8gQhP���l�]��O������.N��8�OPu�"gGB���t�����y`��m��l)9���籚(����K�΂�3q�p�Ϛ?�@�����?�և����5t}k
������?����\���_��(�?���g�G�R���6N�q��6v�sV��]��j�]z�2d�(O���O�Ql_��p�y�ٮ��ݶO��6/�$��G��9e�R�ٍ˺�:�cñǛ�-�p0�T��x��
4��$��5��������� �`��>����������^�4`@B�q܃��H�U�-��W��_��1}hˢ7�wV5Q�Ӈ��ٲ���R����[�a�]���G� �^��3 �?�٧g \�j��å�T�b�C �<@�N����l�)���\�+o?��VSһ��km����r����z�>�Y�c̮({�\�U�Y��`��e�{�}7�?=�[����og XnK*�Z�XmIW��o80�O�b�ǃ�l�F��Dy�w#��`����O��ܤ]=7��u���Ԑ[[i�M����&eL��~��I�h����#��Ǭ��g�nJ��T�HI2�+Zo���|��Y����DZFB3�Ӿs�)V\6�ѡǇ�1��,�Ds|Y9]}7�^4@A���G����}��@U\�������10�QP������JP	�C������3��e������C�?��C���O��ׄJ�!���A�4�s3F����>��B��<�G��n�A�I�x!����Y?���
����_�?��g��z��*��e������h$�g�,腹�%ktj1ѧ�_{��,V�.饑n���w��(��vCI�,��I'Յ�ߌ/#]z-y�;��Bo���k9�>NmZ0���@��O�O����|<��"�~���C���?K��W$��}��a��"T���l�@�;� ������W��jB��/޾�?h#����{��)��*�f�����_��c;2�YSj_�	���jm=��e-�ߊ���U�\`?2�}{����[+����[���3��N��ao�~���~�,��:ێ1J{'Μ$S}�d����C�+u���xĭ��|����gv�0�q^V(�isZn�C֣�K;.���H=C��ح���f�߮m'V�a�[��=��I�$`�aoU�]���P���=.�X#!�L�����Tv,�+k�L��b��gѼ_
�Xh.�^�S4&��c�	'y֌��ft6ݘ��,m�j�Za���&#�3���"�w���PDz,�2����j���	��?8�U@��{�?��$(��	��?����'��,�� �a��a�����>N��9X H���[����������˗��$��'�����_����_������d��W>���o?���	x�*��{���J���8�X�S��U�*�>������_?����u�f��p����_;�O�?@�W��!j�?����<9��?*Z��U�*�����*�?@��?��G8~H�?�����������͐�������a���" ���RP����?А�P	 �� ������&��5���[�!�����h�?�CT$��'�4�?T�������z��'��+�/Ob��P����	�}o������J�����@������ ��0����������#��?�_@@���K~H���5 ���[�����W�8��:���q�ql0�C��p~��<�>h���$��3)}��|! 8�|�f�����u��S,�M�S�?j�k�]����v�Zq��T�Jm��oހe�8�����ISHV�y}q���$2�����n)QXukKCєEq�?ɹ���pWe˗�F9�7�:mQ�ѣ�{��̅i�#�u�vˋ��Mӣ�'#�Ŧ�/=����&��Ej�_J��'U��P��C�g}���XC׷V�p����> ��0�S�����ǵ������C�W~f�7)�97}�h5�z��y$w��Y9l_�e��1S����ωV�h�ͲI���/�Y�>*�|��1��Z��sK�5��Q
��v��f綸�eЧȬ8�kGe�]*cB���@���p�;����������� �`��>����������^�4`@B�]?�������_�%���Y�I�tD�cy�n퉕/O�[�/��Z������&�ɓ�6���:���?*��U�͆rZ	;��;�,��Ac3%؍���¡���v/��0��z8��%��� ��Tn����]�þ㛹�N�Qۍ�O��-����ɷ��mI�!]�{)V[��'.E{sY�O�b�ǃ�l�F��Dy�w#����c�O��ܤ]=\EC�d�Ýw'(��B�dP	?�~�4�6��ٛ�ǣ�h�V�.&�6��(b+��T#f�j}h��L�3a�qG���m�p;뿿�����E��o_������	��J��������S�?���(��$���+�G�_�`�YTq����i����� 
�O��c�������k�'dz������?���?'����[���Ȳ8�|��0���ʶ��;� �f�2:pE������"������Y��W�M���{�t�����]�X~�{���[~���*��SϷ8|m]��߭��ͺ�9����ϱ%cGt�8��j��Ր��6Pgw���B]�9��*6`��x�
{���2U�����O�ek1��'#��(�S��H�a�k�MG�6�.��)��r�O	��8b��E˿Xy/�?��s���ZH�T�}-*��n�a/��\�:MC~yO̔�J$Y�����Q��m��a�-��{jv,����s�챕O�+�96;�"�b"��^b��]�
�G���Ƣ爓�p��F�I&"R�k���M_*��?���0$�|�J�S�
��8���������݁��c����[��\��KP~��y�&}aN��}�fCa��$N��y�є0�).`C&ģ@ ��lvP��������*�Ϝ�W�x.v��Q$�:�1՛���`��Ǩ{���g��O���r��j{�\�����V|���f�����4�U �Gpԣ���T���aTq�������?�_%x���7�����i��w�DH㋩r�	;�����T���E��@�Z0/���`�����>��a?��ݬ?����!�w�����m��E%�cI%��pGVf�%D���	�����!��ׂi��l���苐�M�y�.g�s~>.'�V7N��;��~�{}���=���@-7�$6�Dt��<jp��o�;Q��eڲ��XԦ�RԱ羟�L��j0i��p7��;ф�W���D�q&hZ�f�!�_����[ʜh.�m���Q�;m{cm٥��f�����q�կ��݁��#�����o%�����lH���N�y��u�B���E�<��y�ǯ^u��'�'	�����*�����������g�����Dd��s8�YP��Zo��a�Ǖ���uf尓|���^��T�^��߷�?����w����WP�W����p�U��Ͽ�����?����_��b����v2�������?��	�%x��#�����?Z�nS�܍e{=������>�?d?=��5$�������V)���>*sqQ�>7�$z�8*e(Ӌ�T/��������������b�T{�����սs��]������ض����N�[�n��S'�
Pl�oo��� ��S�_h��Nt&��4���S��� ��{���Z{)L�N�Y�V�x��ʯ+ᅽ��pR���<
�q��mm�y��S9�Z�Y��}��@Vc�;��񩶪0��{0�Y�����iۮ�ܒ#-WĬ%p���jV�+%�L�)�������� č��R����	�xsh����0�]�������b۰%�i�-��Ȗd�yQ�����UBS�5�I�cʳ���ǫ�p�W�>�W1�h)�F�Κ�����`WLI���J�;J�,�=�Q�_^P+��Hz uY���~���<�Ե��!�'��������m�y�X�	Y�?��\����|�3�?!��?!�����{���1� r	���m��A�a��?�����/�%���� �ߠ����oP�쿷��ϫ��J�����~��!��φ\�?Q��fD6��=BN ��G��W�a�7P�:.�������OS���SF���������\Y���ς��?ԅ@DV��}��?d���P��vɅ�G^����L@i�ARz���m�/�_��� �����t��������?���� ������������.z���m�/����ȉ�C]D��������?��g���P��?����R��2��:6��#��۶�r��̕���	���GE.���G��C�?���.���H����[��0��t����_��H]����CF�B���(��K��Ռ2C��\�ʴ��6��%�4��IgX�^֒-,c�e�/r$�~�����Ƀ��K��������)��-����/��*4Ŧ,�r�ɔ��eIzzW�L�Z:6���wژܩ[$+�q M����4��7h��UhGl�#;ړ����	�t���Z�M��@���3[;�j��Z�9WrOp=M�kVo���V�8��[�����d�F{P^�_u>�{���sF����T���Y�<����?t�A�!�(��������n�<�?��������MZ��zzLLD��F!.f0�[����%~Ֆ;{����Ѫ=o���n^���6j2ذ���G�u�T�ow|�^4�m��UM���c$��ۥ:v�9���x�B�T�I����|��E�E������glԿ�����/d@��A��������DH.�?�����`�e�7��=����_�eGA�mO�Y��#W�>o�t�_m����ϧXk�L�|}%~e���۰��m�b�덻,I���,:���7��Ѽ���_�ø0��qaˇ�5�N�/'&�W�l:R����Z��E���*��q:l���+�)0g���~�5̫�G[�?���&;�jM���4�x*��a=��+£-88'(qb����ͪZ��6�K�{a�)��W��@	�S��.Eue���[eZc��`a6��T���0-EU	Sj�c!�@H���:�fi���˻��mC&�v��	��Oo�$��B�'T�u���{�,��o���W�?�"�dA.�����Ń�gAf����e�?�����Z�i���gy�?�����n����O]����L@��/G���?�?r�g��@�o&�I��
d�d���[�1�� �����P��?�.����+�`�er�V�D
���m��B�a�d�F�a�G$����.�)��Ȅo�����s�����A�q|lU�ބ�[�E��6�6�Èkݧ���}��H+�?���z��H?�3�i�����IS>�����~��7����v�Nԯw�U��;N��B�e+sf�o����ސ�>��ٙ9���	�F7�З��0c��d�O�MM��WGi�/�G�~��~�+y��^=mQ lGZrAx>�do+(��X����b,(��Ih`��~gbW���S��p�Q�����jҖ��M�:�7�al`��M���ɰ[�(b!��Y����}+K�!����Q���0ȅ����@n��Xu[�"��߶�����d�I�_�(@�����R�����L��_P��A�/��?�?�@n�}^uS�$��߶���gI�D�H��� oM.���GƷ��J%��Q�Qݎ�F}	ǕK#�e���O5�_�������Dkolzkc3:>�)�^ ��˧��>����c�t܆F/%���{�:���~SѦ-z���b�	L��^���i�[4��A�C������7�e�|q����I & K� ~/�qOP�qc]X���Хa_���)s��ͷ�(��ZX޻�=Yֻ�"�ayӒ�C����
{M�,b���s\A�&T����w��0����+�@��L@n�}ZuK�&��߶���/RW�?A�� ?�ϔ�Њ�eq���K�9/�:m���1:��M����R�Ej<iY�a�<g�K<=縏�[ݿ?3y��k�B�6���?���;�[��3�?a#�<��F-G�~8��ڪ���Ө\x^��X8z�h���Z5��"���Z�1y�*�·������*w*9tayv��9���|\'f�jY��%�C.����|-y����':����"P����C��:r��������`��n��$��:~���w��bY�;�*s�+F/Ŗ�o=D�ݝ�;Qw���q}��n��-��~�i<�\fMH1������;!�#^��b~l��]�!�U3j˺��<�#:k/�xZ��������|���_,�@����C�����/��B�A��A������r�l@4���c�"�����7N�?[�l�=,����E�r9��[ҽ����O9 ?���c9 ��B /s 
+;�i�*m5�[��/�V����NӍբf��-*1��؊(�Y���ן�Ŧ�V�ub���ᇪ^�J�Bk��KI\��4���5!�w��<��Z�F<��.��`(�aM�����ص������	{��K%ٍ��Z�*�Nȶ��p"p����d���7�D)9O$7�j6Q׆�~iHO���m���"�U�@��"Q��4���͖/?�O��]r*=�k{vlYˋ��x��5��(GnO���ƈVz�>�����Q�i����߭�/�<}�����u}�7��d�����tw��8w����?3�"�{��?�����M���"�&�=E�(��aP��3�`���Cz�;?�,gm��ӝ�>�
r�1��w�.�w����~���������t��QZh�k��%fr�O^�8�1�c���J����|>�o�k���)�j�[����}�7��(��*����4�����o�E�K�Z�����Ճឋ[NF�^�O�7µ�:}b6�;�Ќ�;s���bF��lN#'}�LL�I��ٹ�&����#ˁ����č]����N���G���>�{�ܘ��d��߽�E������'U����_�������q?�'���b�o�%9���>=����ߧ���DER8o�����/��?n���b�f��w���c-iW����7��9�� ??Nx��OW���Zrx�:7}�ǋD����:���y>}�ĝ0ܙ������ǁҬ����^kA�I�n����`������\��W,\����[��;��K|���5'�`�o�y�6��������q>ĝ�_�O�d"�_s�܄��s��=�5�OOV���N)i�q��U�%7���U?v����f�#�[5E~��.N"M`؅�h��.����޽�a�����__�S7��������M�Q                           �%��@�� � 