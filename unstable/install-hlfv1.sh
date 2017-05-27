(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

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

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� J_)Y �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/������|�tN7n�O��/�i� h�<^Q�D^���Q�H��/�c��F~Nwc����V��N��4{��k��P����~�MC{9=��i��>dF\.�X]ɿ�&���W&����'*���7������r��$�U�/���m��bo��˟@+�/�$�����q�2.�?U���_��k�?�xv���'=�(`� ����Z�{��\@P���/��'�������g�^����c��P[sp�<��)�r	�i�)�!	�\�(!�i�d0�v<�tQ�	�&���W��(C�'����?N���?^|��RC��?��_��Y������.��km�:�AJ��&���ĻlR_�L~o�Q�k�VCٴ��MfBj��|����F_!X�b3h�q<u��ؤ������D�)�F=D!���t��S�N'[	��n C�T��>am�}yq �HqՏl���_�k߾A�Ί�������7�/��Eӥ������0�Z�+%�������ď<���8���He�K��ϋ�!K2_��[�/�|��y�vC��eMYJ|2�{[f���-�e�6���|��i� f\�hY�%����98��R<��甶�I�=o݈L,C*�v��v�:���,���5$g�H�9QW s��D�݆�p��~|w�z\��P��-ƣVύܝ�#H0D\�\9^���H0�Lޫ����Ď��L�4��x :t�sh�su�4���6�P�I308׹�`uS��F���c�{q ~�-]̅�4.��O����xk��X��?�&��B�7�D��bD(m����|7�Ȕ�	Ӱ��X�1je�>�����f9+�d�r�v���,7Gq�;S��kQ�с�@��'�"�xy2��4��������5���'�K
P80y�(r�r�,��t�1)m�&Fv��Ê	��R=0�6H�\�h�D�i��.C!J !P�/k<y:9�����	t	#.b�fu0���n����ڹr�Iڒ�hj�x1��C&K f�ȱh�sfы��(�e��f�߭�����6�@������|���?�^��)�c(�W�_^�qV�����#ü�ީ��.Yo	$��-����9ǉP�1�%�
��Q�N����٩pP��*�*HvQVp?�+3��L�� ��,,LCѕ�.�,�`w�8b�N��(��K�T�s԰�D�/['RS�w�й[��n�Ǯ�{E��bn5o���P �{-C���O�e�Y�l�S�r!<QuhM���ãr����)gF���U ���@��O7�q���1�����8�t�܇�.��w|K3ymJ
�(�Hs?�4���\rآQ�R�l�9��L�k|'p$�,���&��/�D�p����t��<�1>�@��亖L��)�fV}ȡ�a��?����k������$IU���C������{��F����@�W������/��7�^�������_��g��T�_)�����_�ҧ� 'Q���f������); 	h�e0�u(��%�q�#�*���B�%��Q�UU�_	� ��o���~�Ѥ���#��u�u<K�sED ��e�?������-ض�`FL�9i��e�l)�z�"��Ɨs�3ܠ��Ȃ�`�͍9�Z�+���u�`5J�`�Y��4��ދ_��������K�G���������j��Z�������w��������|���H�O������L���7s(<:��P�қ�]���O�������:vK}�������`p�{;h2�} ��U�>2�2<�$�zo*ͭ��3A>���w���]����t�x�͆�f2o�z�D���D!P��ǅ�.u�A��U;Ǝ�Y�{�u�9Ҷxd\�ǌ�#}/8���sr��8m�<V	�Ti��� =����4�+qz��	'��>Cm��LBDy�Z|g����haڳ'�&Te p�� j��a���ЬG����l�]wZ����Ҟ)-K�z��͎���#JH;#)ɜ�H^�n�@B�<�+���z�Z��|��d�?1���+�/"�������T��W����������� ���ѢA��e���B�/�b������T�_���.���(��@Т�����%��16��EЏ:��O8C������빁���(���H��>��,IRv������_����$Q�e���?�	�"�Z�T��csbkL�6��s�U�����Г��b�J }'��N�VRjhH�(�Nb{��W#�D�Q�[��nno��P�' �!H�g�A+z�d�~8�����fU�߻�X�����?�����j���A���y
�;�����rp��o__f.�?NЕ������A��˗����q���_>R�/m�X�8�!���R�;��`8�|�']����O��P�"�g1"`1Ǳm�el��P��%X�=,�h��]�� g	&�f�G����P��/_�����O�������.���}�Z"&
/&�nPo��4L�˹z�t�H�����?�M��]��簺��\��@w��G��p��|�y�H>h��[>#~*�m��C��Z�D\TG��A�ك��W�?��G��K�A���T������CI��G�����||��?��4[�B�(C���(A>��&����R�Z�W����������]���X��a���ǳ�>�Y@���g�ݏ��{R����]R�z�F��=tw��ρnX�΁���~�9�Ѓ��v��3q�p�i��N�c1/��]j�i���Mb�ڷ�M�	l#ע�iV��X�g�����z�N��7o�(6W3����V\4�ߛ��
�[g���|�G�-ãe�q�#=�$l뜾v�$�\h���@8�5u���(J�&���t�*�)�sj�N%��ǆĭ�0����@ u�3"�mo�ey����A�Ě@�D0�ljN�����|sO���F���4�r�Yf<%���?m{�ȡ��<wJl���'�M�V������Z���"k�JC�y�`i�_����+����?�W��߄����Va�o�2�����l�'�R����m�?���?�m�a��o��N2;M�p�g�?���q�(�g���@y@wA޺d�d����a�5`�uM|�����=8"1��C�MIiK[TwDck6�^�͵F߲���m{���L�ص4�aH���dNS�28�PеDr��8�I�� ��B��<���]��?v�Y�|�9���f-x6���nڷW�`�5��\��^J�r��{���,�C��z}��{���46a�Dw�h�"�������i�_:�r���*����?�,����S>C����ʐ�{�����Y����j��Z�������7��w�s���aX�����r�_��]����U�g)��������\��-�(���O��o��r�'<¦i�xD;�8�.C�F��O�L�8��C�O��#��b��`xu
�o�2�������_H�Z�)��J˔l99�[�Ԍa��"4����V�X�<�-j���c�鸭��+�{ɚ�zb��vp�*�(�9����Q���w-���3�(C�Sez��RGYl�C�j��{����O���8������s�Gmz�Qx ������f���Z���2?�N]?�
�j��/��4�C�km�O�t�{a�����S�ʵ���"��k�����>}�_n�i�����|�Z��&N���4�����.�û^�᧧&q�ξ��_4B_����TVL��^z_k٤v���zz��Q���UQr}\����ꓟ���}��|�����>pr^�ʩ�6X|=���ծ��l��&���5|ɩn_��-n�{���K?�Y�Q1+\���fP���W��9O�վ2�n�]4��� �~�UQ����7D�.��ߐ�ӟ[�}���F�+|;��������>�z��8N�����\;��ξ��.:J�'ߺ�o^m-���DYr簽x�ӿ)Ɔ��w���_���I"}�����=<��>j�O�� ��������wӻ]��o�����{���s�=�����E�����w�j���2����'k8�{=��ԅ��z�q���u{$�{�����%,l r4�ȏ���<W��	���G���G>���cO��c�p�z�6�\d��.��M �|Wođ�ѐ�;0��G�q[U����\l*������6���+Ó8[�[;���>{R��CE?}�'����]m��d���rx.\%�� �1����뺗�u�麭{ߔ\{���֭=�މ	jBL0�%h�$h�����~R�4��H���#
1Q?�m��lg�9;����M�����ҧ��������<�i����%��d:c�lr�rSn%d"v���D2A�")<]F;�Y#�L&���LG�a\��e혀��I��,/L��p:�ǭ��7�r`��ѱ��b 6t/��5 h��s�3�ۄ�J�ńq!v�E�Q�%I������v��k�&��u#��
�k�Cn��4�0�Rt�kq���3V3EL<�d�v[�t�ԵQ�w����|x�Y����P�����&3ّ鶐-$��[�'�%��*|��H�w�w�8g܄�e���_3�\We�ДF�#!2�R��8�.�F�j�5�w���Bi1^2f^�[��[7gyQc4E��)��F�E�E�e�6��Q�ti&Nm8=�����_�S�;��ɉ����4�b|�\]������iU��=�s�g�w�yN��S�9�uPK�!ˠ�Hҩ��#U��q���YG�S���=�Re�EXs�7#�ˈ�H���׌�����|t�D��8��U���.s�fGW���u�q�]d��SyV��R�6y����U�.r�\�lQ�I�Z;[3o u��j����g��d&/G��O�����g�uT�h��*�7V�x�s.���=��k�n���4m&?�t눅��8/��f��8��ˈ	���91�{�*���v.����7��Z��|WW�%�Ѕ����÷9Z���������3w��T��WU�1�p�i�捣�����#`>��&�m�߭:����F��f��������w?�W��!PX;�qj��?���Z*q�m����<�j �S��ȶ�W�~ԍm{Y�^϶�Zu�� Ώp��r���������g~��c�V3�=��o�_~�k����W(�v+�x��~�׌�����w��^�s�G��U��3�o���87s��' 59cS��xS��~qS�#0��)n^�gq�������"���\���zt��K�x�s��:^��'���Z�����o����.�6�����۰;�(���`� G�~�t�9!"om��Wh3�B��^����\?_%w����|q�G�L=_N�s��[��K����6'�Ka�ȳ�Nw���)%�
G{����4�����b=�DY|"�H��[�(�2�젯d����"R��ճ�%���(W���������\
Jj��жJ�*S,����RS
��z���`���z��̈́���6v&,���2��a�S�z�km�	����-5C��֞�+!�V5���֢隒��� ��U�O2Ii�M��\=.�}-�x��&��\�D�����	�w$�3a2�p��	�CYIf�a�H�����P;�a���O�sȺGxFv�`Y�Nd&h?�U�C��Z-+�]����O�"M�i^�Ɓ�a�4W�4��g���f"X���!�h�����Ϗ1�}��|��%|Lʲd�e�rg6s�)��Rܷé���;���4�
H��#Т��Z�p>�!��,��WB�0VL��&,�)��VZ��++�*hnS�S���V��.����i����LKJ�)��٥�U=x�W�iߐ$�.�[V�4�]�HT�z��&-∩,�a����D��B�*����H�ɔ�B5���b��*.���[�,����_Y�+(K��x�B�
�GI��g�����&���j��v��~%��-�0԰�ƕhQ��ɵ�J�����#1��&��pNY�b�&�܋������r�3e�A�e����ReaB��w��������PR���t��5�r�l�M�}� �o6$u�G$�ZS�ڄ��y
u�P�d�"[� ��ۓ,v�~��}6�g�}��|��S��Ӝ(����ڼ�A�έ]	m@k�)�+6�@�M�J[�<`|]����Sy֡3�y֯��*ͳ�CU�q�.ȶ9��˝6t#t���u55K�np�Py�sPJ�j� �	�܀s��qI�ܸ�D�b
i^k�5��MUu=���[ZG�Z�N���,ɖ�\k�&S�����5�����!g~�aݦ�ꜳЙ�� 0��~� n�<+�*fˡ[��u�k��1U��m���Ĵ��).+z�<8�+���
�9��3�=m �@�e��x�AN�, �j3����r���ou�#7�"/o�Co�C[�-�~)�_
V~)x���{��`�Zx�n��R�T�X!H�pw˳��[xP8��-u$D�RGc��pv4h��F��5�=E�ꂃ�=Np�'���1ݬ)����A�=`� |"���w�Ԧ��I��a#
a�@e�HqKK4�C�G�!$��z/@r^!�E���SʣyݹM��ƕ|��0X�q��ʡ�=8T�x
��{>�G�B�8��Ocb<$��Cv���5I�� �Q�7��w����J1���H��0�K����>�H������RPQ�ٰi�.Ε��5�0������>Ջ	���n���T׺��) �ԡ���L�jZ������ᴍ�6�8�c]�^���m�Sy˔sy���Ǝ�t��ϴb������o��p=t�ʰ��N<,���{���'���?����r_ˎ�}p"i�"����(�+I���U.�D똗`s
d���Gv�T,E�:΃Ճ"�LPdG�LZFA��fMYVz<�-\��C��$01������H2�#b;�qj�@����A�`J�G�.
@��tI��(����rw��(�.�$��	�ha:�7ٍ���v�n�ÄH�-5�vԳ����<9$�J�m�>�|ig p�X������WJU�$/�a�g�B��Q?��]ْ��wxX[�\ �dI^+�K�H��M�Z�D
�.����e�m�o�q(��=�[�)s�)�ɱB�k���
a����V3lb�l���ZKȴ���f�p�?z�aJ|}��+��4^�{�p���?�ǅ� � 6!Z�2Q���w@p�^�{.�j4I'����{X̮W��[���4B�����z��w}饿<��ǡk��@X��v�k���f���\ǁ�OԻw����^���g���O��/�q�ǿ�t���7=�͛���_M����������8�N���kWx��+�+z��k��D�
��}#��+?��g����t�g�����_�Ƈ��^��k�G
����'��,��U��iS;mj�M�i6�����~��k�퀴M����6����l���@�<4��2�A/�T�
��F�a��`��ݶ�:�x��c��31t������?qzm���"d�l���؟R�O�6��6�8�3��8�G`\2��|�65�f��eϙ�����{Z�=-��3c�m�a����a
�嘙s��p���J�|wɣ�H�<.~��Ak���?;��Nv���6���\�  