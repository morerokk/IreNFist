Hooks = {}
Hooks._prehooks = {}
Hooks._posthooks = {}
Hooks._hooks = {}

function Hooks:PreHook(class, func_name, hook_id, hook_func)
    if not self._prehooks[class] then
        self._prehooks[class] = {}
    end

    if not self._prehooks[class][func_name] then
        self._prehooks[class][func_name] = {}
        local old_func = class[func_name]
        class[func_name] = function(...)
            for id, f in pairs(self._prehooks[class][func_name]) do
                f(...)
            end
            return old_func(...)
        end
    end

    self._prehooks[class][func_name][hook_id] = hook_func

end

function Hooks:PostHook(class, func_name, hook_id, hook_func)
    if not self._posthooks[class] then
        self._posthooks[class] = {}
    end

    if not self._posthooks[class][func_name] then
        self._posthooks[class][func_name] = {}
        local old_func = class[func_name]
        class[func_name] = function(...)
            local result = old_func(...)
            for id, f in pairs(self._posthooks[class][func_name]) do
                f(...)
            end
            return result
        end
    end

    self._posthooks[class][func_name][hook_id] = hook_func

end

function Hooks:RegisterHook(hook_id)
    self._hooks[hook_id] = self._hooks[hook_id] or {}
end

function Hooks:AddHook(hook_id, hook_clbk_name, func)
    self:RegisterHook(hook_id)

    self._hooks[hook_clbk_name] = self._hooks[hook_clbk_name] or func
end

function Hooks:Register(...)
    return self:RegisterHook(...)
end

function Hooks:Add(...)
    return self:AddHook(...)
end

function Hooks:Call(hook_id, ...)
    if not self._hooks[hook_id] then
        return
    end

    for hook_clbk_name, hook_func in pairs(self._hooks[hook_id]) do
        hook_func(...)
    end
end
