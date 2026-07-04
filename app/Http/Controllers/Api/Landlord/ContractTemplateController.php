<?php

namespace App\Http\Controllers\Api\Landlord;

use App\Http\Controllers\Controller;
use App\Models\Tenant;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use PhpOffice\PhpWord\PhpWord;
use PhpOffice\PhpWord\IOFactory;

class ContractTemplateController extends Controller
{
    use ApiResponse;

    public function download(Request $request)
    {
        $request->validate([
            'tenant_id' => 'nullable|uuid|exists:tenants,id',
        ]);

        $tenant = $request->tenant_id ? Tenant::with(['user', 'unit.property'])->findOrFail($request->tenant_id) : null;
        $landlord = auth()->user()->organization?->owner?->full_name ?? auth()->user()->full_name;
        $property = $tenant?->unit?->property;

        $phpWord = new PhpWord();
        $section = $phpWord->addSection();

        $section->addText('TENANCY AGREEMENT', ['bold' => true, 'size' => 18, 'alignment' => 'center']);
        $section->addTextBreak();
        $section->addText('Contract Number: ______________________', ['bold' => true]);
        $section->addTextBreak();

        $section->addText('PARTIES', ['bold' => true, 'size' => 14]);
        $section->addText("Landlord: {$landlord}");
        $section->addText("Tenant: " . ($tenant?->user?->full_name ?? '______________________'));
        $section->addText("Phone: " . ($tenant?->user?->phone ?? '______________________'));
        $section->addTextBreak();

        $section->addText('PROPERTY', ['bold' => true, 'size' => 14]);
        $section->addText("Property Name: " . ($property?->name ?? '______________________'));
        $section->addText("Address: " . ($property?->address ?? $property?->location ?? '______________________'));
        $section->addText("Unit: " . ($tenant?->unit?->name ?? '______________________'));
        $section->addTextBreak();

        $section->addText('TERM', ['bold' => true, 'size' => 14]);
        $section->addText('Start Date: ______________________');
        $section->addText('End Date: ______________________');
        $section->addTextBreak();

        $section->addText('RENT', ['bold' => true, 'size' => 14]);
        $section->addText('Monthly Rent: ______________________');
        $section->addText('Deposit: ______________________');
        $section->addTextBreak();

        $section->addText('TERMS AND CONDITIONS', ['bold' => true, 'size' => 14]);
        $section->addText('1. The tenant shall pay rent on or before the due date each month.');
        $section->addText('2. The tenant shall keep the property in good condition.');
        $section->addText('3. The landlord may terminate this agreement for non-payment or breach of terms.');
        $section->addText('4. The deposit shall be refunded at move-out after inspection, minus damages.');
        $section->addTextBreak(2);

        $section->addText('Landlord Signature: ______________________    Date: ______________________');
        $section->addTextBreak();
        $section->addText('Tenant Signature: ______________________    Date: ______________________');

        $fileName = 'contract_template_' . ($tenant?->user?->phone ?? 'manual') . '.docx';
        $tempPath = storage_path('app/' . $fileName);
        $writer = IOFactory::createWriter($phpWord, 'Word2007');
        $writer->save($tempPath);

        return response()->download($tempPath, $fileName, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ])->deleteFileAfterSend(true);
    }
}
