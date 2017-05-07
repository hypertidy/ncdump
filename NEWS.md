# dev

* removed all old data_frame uses

breaking name changes


dimension  .dimension_  = id,  .group_ = group_id
dimvals   .dimension_ = id
group    .group_  = id
file      .file_   = id (this should probably be replaced ?)
variable  .variable_ = id, .group_ = group_id[group_index]
vardim    .variable_ = id, .dimension_ = dimids

dimension was dims
dimension_values was dimvals
group was groups
variable_link_dimension was vardim


# ncdump 0.0.3

* initial release

* ported from rancid



