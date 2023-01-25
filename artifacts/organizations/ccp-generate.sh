#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s/\${PEERORG}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=Japan
P0PORT=7051
CAPORT=7054
PEERORG=japan
PEERPEM=organizations/peerOrganizations/japan.eapvp.com/tlsca/tlsca.japan.eapvp.com-cert.pem
CAPEM=organizations/peerOrganizations/japan.eapvp.com/ca/ca.japan.eapvp.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERORG $PEERPEM $CAPEM)" > organizations/peerOrganizations/japan.eapvp.com/connection-japan.json
#echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/japan.eapvp.com/connection-japan.yaml

ORG=Pvpp
P0PORT=13051
CAPORT=13054
PEERORG=pvpp
PEERPEM=organizations/peerOrganizations/pvpp.eapvp.com/tlsca/tlsca.pvpp.eapvp.com-cert.pem
CAPEM=organizations/peerOrganizations/pvpp.eapvp.com/ca/ca.pvpp.eapvp.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERORG $PEERPEM $CAPEM)" > organizations/peerOrganizations/pvpp.eapvp.com/connection-pvpp.json
