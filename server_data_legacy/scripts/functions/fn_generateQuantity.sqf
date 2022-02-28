private["_used","_qty","_text"];
_used = _this;
_qty = ((1 - _used) max 0);
_qty = round(_qty * 100);
_text = switch true do {
	case (_qty == 0) : {"Empty"};
	default {format["%1%% remaining",_qty]};
};
_text