// we bind only to the rateit controls within the products div
$('#rating .rateit').bind('rated', function(e) {
    var ri = $(this);
    // if the use pressed reset, it will get value: 0 (to be compatible with the HTML range control), 
    // we could check if e.type == 'reset', and then set the value to  null .
    var value = ri.rateit('value');
    var spotId = ri.data('spotid');
    // if the product id was in some hidden field: ri.closest('li').find('input[name="productid"]').val()

    // maybe we want to disable voting?
    // ri.rateit('readonly', true);
    $.ajax({
        url: '/ajax/rateit', //your server side script
        data: {
            id: spotId,
            value: value
        }, //our data
        type: 'POST',
        success: function(data) {
            var obj = jQuery.parseJSON(data);
            $('div[data-spotId="' + obj["id"] + '"]').rateit('value', obj["value"]);
        },
        error: function(jxhr, msg, err) {
            // What TODO here?
        }
    });
});