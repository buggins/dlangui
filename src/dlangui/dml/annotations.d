module dlangui.dml.annotations;

/// annotate widget with @dmlwidget UDA to allow using it in DML
struct dmlwidget {
    bool dummy;
}

/// annotate widget property with @dmlproperty UDA to allow using it in DML
struct dmlproperty {
    bool dummy;
}

/// annotate signal with @dmlsignal UDA
struct dmlsignal {
    bool dummy;
}
