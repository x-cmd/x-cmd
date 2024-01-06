END{
    if (OPENAI_RESPONESE_IS_ERROR_CONTENT != 1) printf "\n"
    else log_error("openai", log_mul_msg(jstr(o_error)))
}
