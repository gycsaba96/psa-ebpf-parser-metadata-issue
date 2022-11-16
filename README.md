# Reproducing PSA-eBPF parser metadata issue

The [new PSA-eBPF backend](https://github.com/p4lang/p4c/tree/main/backends/ebpf/psa) doesn't support parser metadata correctly.

When I try to use metadata with the type of `psa_ingress_parser_input_metadata_t`, I get an error message from the clang compiler.

Input:
```
parser packet_parser(...,
                     in psa_ingress_parser_input_metadata_t pipi_md,
                     ...) {

    ...
    
    state parse_ethernet{
        pkt.extract(hdr.ethernet);
        transition select(pipi_md.packet_path){
            PSA_PacketPath_t.RESUBMIT: reject;
            default: accept;
        }
    }

}
```

Error message:
```
out.c:341:20: error: use of undeclared identifier 'pipi_md'
        select_0 = pipi_md.packet_path;
                   ^
```

For reproducibility purposes, I created this [repository with a minimal example](https://github.com/gycsaba96/psa-ebpf-parser-metadata-issue). One can reproduce the issue using the following commands:

```
make p4c-docker-setup
make build
```

Looking at the generated C code, the metadata is defined after the `accept` label with the wrong name:

```
accept: {
    struct psa_ingress_input_metadata_t standard_metadata = {
        .ingress_port = skb->ifindex,
        .packet_path = compiler_meta__->packet_path,
        .parser_error = ebpf_errorCode,
};
```




