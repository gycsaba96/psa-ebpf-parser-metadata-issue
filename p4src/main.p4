#include <core.p4>
#include <psa.p4>

#include "headers.p4"


struct headers_t {
    ethernet_h ethernet;
}

parser packet_parser(packet_in pkt, 
                     out headers_t hdr, 
                     inout empty_t ig_md,
                     in psa_ingress_parser_input_metadata_t pipi_md,
                     in empty_t resub_meta,
                     in empty_t recirc_meta) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet{
        pkt.extract(hdr.ethernet);
        transition select(pipi_md.packet_path){
            PSA_PacketPath_t.RESUBMIT: reject;
            default: accept;
        }
    }

}

control packet_deparser(packet_out pkt,
                        out empty_t clone_i2e_meta,
                        out empty_t resubmit_meta, 
                        out empty_t normal_meta, 
                        inout headers_t hdr, 
                        in empty_t ig_md,
                        in psa_ingress_output_metadata_t istd) {

    apply {
        pkt.emit(hdr);
    }
}

control ingress(inout headers_t hdr,
                inout empty_t ig_md,
                in psa_ingress_input_metadata_t standard_metadata,
                inout psa_ingress_output_metadata_t ostd) {

    apply {
    }

}

control egress(inout headers_t hdr,
               inout empty_t eg_md,
               in psa_egress_input_metadata_t istd,
               inout psa_egress_output_metadata_t ostd) {

    apply {
    }
}

parser egress_parser(packet_in pkt,
                     out headers_t hdr,
                     inout empty_t eg_md,
                     in psa_egress_parser_input_metadata_t istd,
                     in empty_t normal_meta,
                     in empty_t clone_i2e_meta,
                     in empty_t clone_e2e_meta) {

    state start {
        transition accept;
    }
}

control egress_deparser(packet_out pkt,
                        out empty_t clone_e2e_meta, 
                        out empty_t recirculate_meta, 
                        inout headers_t hdr, 
                        in empty_t eg_md, 
                        in psa_egress_output_metadata_t istd, 
                        in psa_egress_deparser_input_metadata_t edstd) {

    apply {
        pkt.emit(hdr);
    }
}


IngressPipeline(packet_parser(), ingress(), packet_deparser()) ip;

EgressPipeline(egress_parser(), egress(), egress_deparser()) ep;

PSA_Switch(ip, PacketReplicationEngine(), ep, BufferingQueueingEngine()) main;
